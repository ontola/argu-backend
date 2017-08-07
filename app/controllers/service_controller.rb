# frozen_string_literal: true
class ServiceController < AuthorizedController
  include Service::Setup
  # The action creators have to be re-included since they have to be called
  # with the new setup method.
  include Service::Create,
          Service::Destroy,
          Service::Update

  private

  def action_service
    @_action_service ||=
      case action_name
      when 'create'
        create_service
      when 'destroy'
        destroy_service
      when 'update'
        update_service
      end
  end

  def authenticated_resource!
    @resource ||=
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
      attributes: resource_new_params.merge(permit_params.to_h).with_indifferent_access,
      options: service_options
    )
  end

  def create_service_parent
    parent_resource!.edge
  end

  # Prepares a memoized {DestroyService} for the relevant model for use in controller#destroy
  # @return [DestroyService] The service, generally initialized with {resource_id}
  # @example
  #   destroy_service # => DestroyComment<commentable_id: 6, parent_id: 5>
  #   destroy_service.commit # => true (Comment destroyed)
  def destroy_service
    @destroy_service ||= service_klass.new(
      resource_by_id!,
      options: service_options
    )
  end

  def service_klass
    "#{action_name.classify}#{controller_name.classify}".safe_constantize ||
      "#{action_name.classify}Service".constantize
  end

  # For use with the services options parameter, with sensible defaults
  # @return [Hash] Defaults with the creator and publisher set to the current profile/user
  def service_options(options = {})
    {
      creator: current_actor.actor,
      publisher: current_user,
      comment: params[:activity]&.permit(:comment).try(:[], :comment),
      uuid: a_uuid,
      client_id: request.session.id
    }.merge(options)
  end

  # The name of the failure signal as emitted from `action_service`
  def signal_failure
    "#{action_name}_#{model_name}_failed".to_sym
  end

  # The name of the success signal as emitted from `action_service`
  def signal_success
    "#{action_name}_#{model_name}_successful".to_sym
  end

  # Prepares a memoized {UpdateService} for the relevant model for use in controller#update
  # @return [UpdateService] The service, generally initialized with {resource_by_id} and {permit_params}
  # @example
  #   update_service # => UpdateComment<commentable_id: 6, parent_id: 5>
  #   update_service.commit # => true (Comment updated)
  def update_service
    @update_service ||= service_klass.new(
      resource_by_id!,
      attributes: permit_params,
      options: service_options
    )
  end
end
