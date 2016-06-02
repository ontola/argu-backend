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
      create_activity(resource, resource.motion, method)
    end

    define_method "#{method}_blog_post_successful" do |resource|
      create_activity(resource, resource.blog_postable, method)
    end

    define_method "#{method}_comment_successful" do |resource|
      create_activity(resource, resource.subscribable, method)
    end

    define_method "#{method}_group_response_successful" do |resource|
      create_activity(resource, resource.motion, method)
    end

    define_method "#{method}_motion_successful" do |resource|
      recipient = resource.question || resource.project || resource.forum
      create_activity(resource, recipient, method)
    end

    define_method "#{method}_project_successful" do |resource|
      create_activity(resource, resource.forum, method)
    end

    define_method "#{method}_question_successful" do |resource|
      recipient = resource.project || resource.forum
      create_activity(resource, recipient, method)
    end
  end

  private

  # @return [Hash] The data to be serialized in JSON
  def audit_data(resource, recipient)
    {
      user_id: @publisher.id,
      user_name: @publisher.display_name,
      recipient_id: "#{recipient.class.to_s}.#{recipient.id}",
      recipient_name: recipient.display_name,
      trackable_id: "#{resource.class.to_s}.#{resource.id}",
      trackable_name: resource.display_name
    }
  end

  def create_activity(resource, recipient, action)
    a = CreateActivity.new(
      Activity.new,
      trackable: resource,
      key: "#{resource.model_name.singular}.#{action}",
      owner: @creator,
      forum: resource.forum,
      recipient: recipient,
      audit_data: audit_data(resource, recipient),
      is_published: true)
    a.subscribe(NotificationListener.new)
    a.commit
  end
end
