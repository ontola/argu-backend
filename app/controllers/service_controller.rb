# frozen_string_literal: true

class ServiceController < ParentableController
  private

  def action_service
    @action_service ||=
      case action_name
      when 'create'
        create_service
      when 'destroy'
        destroy_service
      when 'update'
        update_service
      end
  end

  def activity_options
    activity_key = "#{action_name}_activity_attributes"
    return {} if params.dig(model_name, activity_key).blank?

    params.require(model_name).require(activity_key).permit(:comment, :notify)
  end

  def current_resource
    @current_resource ||=
      case action_name
      when 'create', 'destroy', 'update', 'untrash', 'trash'
        action_service.resource
      else
        super
      end
  end

  # Prepares a memoized {CreateService} for the relevant model for use in controller#create
  # @return [CreateService] The service, generally initialized with {current_profile} and {resource_new_params}
  # @example
  #   create_service # => CreateComment<commentable_id: 6, parent_id: 5>
  #   create_service.commit # => true (Comment created)
  def create_service
    @create_service ||= service_klass.new(
      create_service_parent,
      attributes: create_service_attributes,
      options: service_options
    )
  end

  def create_service_attributes
    permit_params_with_filters.to_h.with_indifferent_access
  end

  def create_service_parent
    requested_resource!.is_a?(LinkedRails.collection_class) ? requested_resource!.parent : requested_resource!
  end

  # Prepares a memoized {DestroyService} for the relevant model for use in controller#destroy
  # @return [DestroyService] The service, generally initialized with {resource_id}
  # @example
  #   destroy_service # => DestroyComment<commentable_id: 6, parent_id: 5>
  #   destroy_service.commit # => true (Comment destroyed)
  def destroy_service
    @destroy_service ||= service_klass.new(
      requested_resource!,
      options: service_options.merge(confirmation_string: params[model_name].try(:[], :confirmation_string))
    )
  end

  def execute_action
    return super if action_service.blank?

    action_service.on(*signals_success, &method(:active_response_handle_success))
    action_service.on(*signals_failure, &method(:active_response_handle_failure))
    action_service.commit
  end

  def service_klass
    "#{action_name.classify}#{controller_name.classify}".safe_constantize ||
      "#{action_name.classify}Service".constantize
  end

  # For use with the services options parameter, with sensible defaults
  # @return [Hash] Defaults with the creator and publisher set to the current profile/user
  def service_options(options = {})
    {
      user_context: user_context
    }.merge(activity_options).merge(options).with_indifferent_access
  end

  # The name of the failure signal as emitted from `action_service`
  def signals_failure
    [:"#{action_name}_#{model_name}_failed"]
  end

  # The name of the success signal as emitted from `action_service`
  def signals_success
    [:"#{action_name}_#{model_name}_successful"]
  end

  # Prepares a memoized {UpdateService} for the relevant model for use in controller#update
  # @return [UpdateService] The service, generally initialized with {requested_resource} and {permit_params}
  # @example
  #   update_service # => UpdateComment<commentable_id: 6, parent_id: 5>
  #   update_service.commit # => true (Comment updated)
  def update_service
    @update_service ||= service_klass.new(
      requested_resource!,
      attributes: update_service_attributes,
      options: service_options
    )
  end

  def update_service_attributes
    permit_params_with_filters.to_h.with_indifferent_access
  end
end
