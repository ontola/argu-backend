# Superclass for all the services in the system
# @author Fletcher91 <thom@argu.co>
class ApplicationService
  include Pundit

  # The resource on which the service works, if any.
  # @note Currently all the services use this method, the requirement might be dropped in a future version.
  def resource
    raise 'Required interface not implemented'
  end

  # Executes the action, so generally message broadcasts begin here.
  def commit
    raise 'Required interface not implemented'
  end

  private

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
        elsif association.respond_to?(:save)
          set_object_attributes(association)
        end
      end
    end
  end

  # Method to set attributes on a nested model.
  # @note This should be used for attributes that are consistent across all the associations.
  # @see {set_nested_associations}
  # @param [ActiveRecord::Base] obj The model on which the attributes should be set
  def set_object_attributes(obj)
    raise 'Required interface not implemented'
  end
end
