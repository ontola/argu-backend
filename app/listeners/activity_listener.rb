# frozen_string_literal: true
class ActivityListener
  # @param [Hash] opts
  # @option opts [User] publisher The person that made the action
  # @option opts [Profile] creator The Profile under whose name it was published
  def initialize(opts = {})
    @publisher = opts[:publisher]
    @creator = opts[:creator]
  end

  # Dynamically declare the listener publication methods
  # @see {ApplicationService#commit} and {ApplicationService#signal_base} for the naming.
  %w(create destroy trash untrash update publish).each do |method|
    define_method "#{method}_argument_successful" do |resource|
      create_activity(resource, resource.parent_model, method)
    end

    define_method "#{method}_banner_successful" do |resource|
      create_activity(resource, resource.forum, method)
    end

    define_method "#{method}_blog_post_successful" do |resource|
      create_activity(resource, resource.parent_model, method)
    end

    define_method "#{method}_comment_successful" do |resource|
      create_activity(resource, resource.subscribable, method)
    end

    define_method "#{method}_motion_successful" do |resource|
      create_activity(resource, resource.parent_model, method)
    end

    define_method "#{method}_project_successful" do |resource|
      create_activity(resource, resource.parent_model, method)
    end

    define_method "#{method}_question_successful" do |resource|
      create_activity(resource, resource.parent_model, method)
    end

    define_method "#{method}_decision_successful" do |resource|
      action = method == 'publish' ? resource.state : method
      create_activity(resource, resource.parent_model, action)
    end
  end

  def create_conversion_successful(resource)
    create_activity(
      resource.edge.owner,
      resource.edge.parent.owner,
      :convert
    )
  end

  def create_vote_successful(resource)
    ActiveRecord::Base.transaction do
      destroy_recent_similar_activities(resource, resource.parent_model, 'create')
      create_activity(
        resource,
        resource.parent_model,
        :create,
        parameters: {for: resource.for}
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

  def create_activity(resource, recipient, action, parameters: {})
    a = CreateActivity.new(
      Activity.new,
      attributes: {
        trackable: resource,
        trackable_edge: resource.try(:edge)&.persisted? ? resource.try(:edge) : nil,
        key: "#{resource.model_name.singular}.#{action}",
        owner: @creator,
        forum: resource.forum,
        recipient: recipient,
        recipient_edge: recipient.edge,
        audit_data: audit_data(resource, recipient),
        parameters: parameters
      }
    )
    a.subscribe(NotificationListener.new)
    a.commit
  end

  # Deletes all other activities created within 6 hours of the new activity.
  def destroy_recent_similar_activities(resource, recipient, action)
    ids = Activity.where('created_at >= :date', date: 6.hours.ago)
                  .where(recipient_id: recipient.id,
                         owner_id: @creator.id,
                         key: "#{resource.class.name.downcase}.#{action}")
                  .pluck(:id)
    Notification.where(activity_id: ids).destroy_all
    Activity.destroy ids
  end
end
