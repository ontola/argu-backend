# frozen_string_literal: true

class ActivityListener
  AUTO_GENERATED_LISTENER_CLASSES = Edge.descendants.map(&:name).map(&:underscore) - %w[decision vote vote_event page]

  # @param [Hash] opts
  # @option opts [User] publisher The person that made the action
  # @option opts [Profile] creator The Profile under whose name it was published
  # @option opts [String] comment An optional Comment to explain the action
  # @option opts [Bool] notify Whether to create notifications
  def initialize(**opts)
    @publisher = opts[:user_context].user
    @creator = opts[:user_context].profile
    @comment = opts[:comment]
    @notify = opts[:notify].to_s == 'true'
  end

  # Dynamically declare the listener publication methods
  # @see {ApplicationService#commit} and {ApplicationService#signal_base} for the naming.
  %w[create destroy trash untrash update publish].each do |method|
    AUTO_GENERATED_LISTENER_CLASSES.each do |model|
      define_method "#{method}_#{model}_successful" do |resource|
        create_activity(resource, resource.activity_recipient, method)
      end
    end

    define_method "#{method}_decision_successful" do |resource|
      action = method == 'publish' ? resource.state : method
      create_activity(resource, resource.activity_recipient, action)
    end
  end

  def create_conversion_successful(resource)
    create_activity(
      resource.edge,
      resource.edge.activity_recipient,
      :convert
    )
  end

  def create_vote_successful(resource)
    ActiveRecord::Base.transaction do
      destroy_recent_similar_activities(resource, resource.activity_recipient, 'create')
      create_activity(
        resource,
        resource.activity_recipient,
        :create,
        parameters: {option: resource.option_id}
      )
    end
  end

  private

  # @return [Hash] The data to be serialized in JSON
  def audit_data(resource, recipient)
    {
      user_id: @publisher.id,
      user_name: @publisher.display_name,
      recipient_id: "#{recipient.class}.#{recipient.id}",
      recipient_name: recipient.display_name,
      trackable_id: "#{resource.class}.#{resource.id}",
      trackable_name: resource.display_name
    }
  end

  def create_activity(resource, recipient, action, parameters: {}) # rubocop:disable Metrics/MethodLength
    a = CreateActivity.new(
      Activity.new(notify: @notify),
      attributes: {
        created_at: action == 'create' ? resource.created_at : nil,
        comment: @comment,
        trackable: resource.destroyed? ? nil : resource,
        trackable_type: resource.owner_type,
        key: "#{resource.model_name.singular}.#{action}",
        owner: @creator,
        recipient: recipient,
        recipient_type: recipient.owner_type,
        root_id: resource.root_id,
        audit_data: audit_data(resource, recipient),
        parameters: parameters
      }
    )
    a.subscribe(NotificationListener.new)
    a.commit
  end

  # Deletes all other activities created within 6 hours of the new activity.
  def destroy_recent_similar_activities(resource, recipient, action)
    ids = Activity
            .where('created_at >= :date', date: 6.hours.ago)
            .where(recipient_edge_id: recipient.uuid,
                   owner_id: @creator.id,
                   key: "#{resource.model_name.singular}.#{action}")
            .pluck(:id)
    Notification.where(activity_id: ids).destroy_all
    Activity.destroy ids
  end
end
