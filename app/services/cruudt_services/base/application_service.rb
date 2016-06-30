# frozen_string_literal: true

# Superclass for all the services in the system
# @author Fletcher91 <thom@argu.co>
class ApplicationService
  include Pundit

  # @note Call super when overriding.
  def initialize(orig_resource, attributes: {}, options: {})
    @attributes = attributes
    @actions = {}
    @options = options
    if @attributes[:argu_publication_attributes].present? &&
        !(resource.is_a?(Edge) ? resource.owner : resource).is_published?
      prepare_argu_publication_attributes
    end
    assign_attributes
    set_nested_associations
    unless resource.is_a?(Activity)
      subscribe(ActivityListener
                  .new(creator: options.fetch(:creator),
                       publisher: options.fetch(:publisher)))
    end
  end

  # The resource on which the service works, if any.
  # @note Currently all the services use this method, the requirement might be dropped in a future version.
  def resource
    raise 'Required interface not implemented'
  end

  # Executes the action, so generally message broadcasts begin here.
  # @see {after_save}
  def commit
    ActiveRecord::Base.transaction do
      @actions[service_action] = resource.public_send service_method

      after_save if @actions[service_action]

      publish("#{signal_base}_successful".to_sym, resource) if @actions[service_action]
      publish("publish_#{resource.model_name.singular}_successful".to_sym, resource) if @actions[:published]
      publish("unpublish_#{resource.model_name.singular}_successful".to_sym, resource) if @actions[:unpublished]
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::ActiveRecordError => e
    raise(e) if e.is_a?(ActiveRecord::StatementInvalid)
    publish("#{signal_base}_failed".to_sym, resource)
  end

  private

  # Override this when you need to perform additional actions within
  # the transaction but after the model was saved.
  # @note This doesn't work when {commit} is overridden.
  def after_save
    # Stub
  end

  def assign_attributes
    resource.assign_attributes(@attributes)
  end

  # The action that called this service.
  #
  # Used to determine the correct signal name in {signal_base} since controller
  # actions can differ from their associated model methods
  # @return [Symbol] The name of the calling controller action
  def service_action
    raise 'Required interface not implemented'
  end

  # The method that will be called on the resource
  # @return [Symbol] The method to be called on the model (Defaults to {service_action})
  def service_method
    service_action
  end

  # Calls object_attributes= for each association that has been declared as `accepts_nested_attributes_for`
  # @author Fletcher91 <thom@argu.co>
  # @note Requires `object_attributes=` to be overridden in the child class.
  def set_nested_associations
    if resource.nested_attributes_options?
      resource.nested_attributes_options.keys.each do |association|
        association_instance = resource.public_send(association)
        if association_instance.respond_to?(:length)
          association_instance.each do |record|
            self.object_attributes = record
          end
        elsif association_instance.respond_to?(:save)
          self.object_attributes = association_instance
        end
      end
    end
  end

  # Method to set attributes on a nested model.
  # @note This should be used for attributes that are consistent across all the associations.
  # @see {set_nested_associations}
  # @param [ActiveRecord::Base] obj The model on which the attributes should be set
  def object_attributes=(obj)
  end

  def prepare_argu_publication_attributes
    attributes = @attributes[:argu_publication_attributes]
    attributes[:published_at] = 10.seconds.from_now if attributes[:publish_type] == 'direct'
    attributes[:published_at] = nil if attributes[:publish_type] == 'draft'
    if resource.new_record? ||
        (attributes[:published_at] != resource.argu_publication.published_at ||
          attributes[:publish_type] != resource.argu_publication.publish_type)
      attributes[:publisher] ||= @options[:publisher]
      attributes[:creator] ||= @options[:creator]
    end
    attributes[:id] = resource.argu_publication.id if resource.argu_publication.present?
    @attributes[:argu_publication_attributes] = attributes
  end

  def signal_base
    "#{service_action}_#{resource.model_name.singular}"
  end
end
