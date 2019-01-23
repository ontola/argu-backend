# frozen_string_literal: true

class DirectMessagesController < ParentableController
  private

  def active_response_action(opts = {})
    opts[:resource].action(user_context, :create)
  end

  def create_execute # rubocop:disable Metrics/AbcSize
    authenticated_resource.assign_attributes(permit_params)
    authenticated_resource.actor = current_actor.actor
    return false unless authenticated_resource.valid?

    unless current_user.email_addresses.confirmed.where(email: authenticated_resource.email).exists?
      raise Argu::Errors::Forbidden.new(record: authenticated_resource, query: 'email?')
    end
    authenticated_resource.send_email!
  end

  def new_success
    authenticated_resource.email = current_user.email if current_user.confirmed?
    super
  end

  def parent_resource
    @parent_resource ||= super || resource_from_iri(params[:direct_message].try(:[], :resource_iri))
  end

  def resource_by_id; end

  def redirect_location
    authenticated_resource.resource.iri
  end

  def resource_new_params
    {resource: parent_resource}
  end

  def active_response_success_message
    return super unless action_name == 'create'
    t('direct_messages.notice.success')
  end
end
