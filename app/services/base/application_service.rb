# Superclass for all the services in the system
# @author Fletcher91 <thom@argu.co>
class ApplicationService
  include Pundit

  # @note Call super when overriding.
  def initialize(resource, attributes = {}, options = {})
    @attributes = attributes
    @actions = {}
    assign_attributes
    set_nested_associations
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
  rescue ActiveRecord::RecordInvalid, ActiveRecord::ActiveRecordError
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
    publishable_attributes if resource.respond_to?(:published_at)
    resource.assign_attributes(@attributes)
  end

  def publishable_attributes
    if @attributes.delete(:publish).to_s == 'true'
      @attributes[:published_at] = DateTime.current
      @actions[:published] = true
    end
    if @attributes.delete(:unpublish).to_s == 'true'
      @attributes[:published_at] = nil
      @actions[:unpublished] = true
    end
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

  # Calls set_object_attributes for each association that has been declared as `accepts_nested_attributes_for`
  # @author Fletcher91 <thom@argu.co>
  # @note Requires the `set_object_attributes` to be overridden in the child class.
  def set_nested_associations
    if resource.nested_attributes_options?
      resource.nested_attributes_options.keys.each do |association|
        association_instance = resource.public_send(association)
        if association_instance.respond_to?(:length)
          association_instance.each do |record|
            set_object_attributes(record)
          end
        elsif association_instance.respond_to?(:save)
          set_object_attributes(association_instance)
        end
      end
    end
  end

  # Method to set attributes on a nested model.
  # @note This should be used for attributes that are consistent across all the associations.
  # @see {set_nested_associations}
  # @param [ActiveRecord::Base] obj The model on which the attributes should be set
  def set_object_attributes(obj)
  end

  def signal_base
    "#{service_action}_#{resource.model_name.singular}"
  end
end
