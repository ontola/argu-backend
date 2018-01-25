# frozen_string_literal: true

class DirectMessagesController < ParentableController
  def new
    authenticated_resource.email = current_user.email if current_user.confirmed?
    new_handler_success(authenticated_resource)
  end

  private

  def authenticated_edge
    @resource_edge ||= parent_resource&.edge
  end

  def create_respond_success_html(resource)
    unless current_user.email_addresses.confirmed.where(email: resource.email).exists?
      raise Argu::Errors::NotAuthorized.new(record: resource, query: 'email?')
    end
    resource.send_email!
    redirect_to resource.resource, notice: t('direct_messages.notice.success')
  end

  def execute_create
    authenticated_resource.assign_attributes(permit_params)
    authenticated_resource.actor = current_actor.actor
    authenticated_resource.valid?
  end

  def new_respond_success_js(_resource)
    render 'new.js'
  end

  def parent_resource
    @parent_resource ||= super || resource_from_iri(params[:direct_message][:resource_iri])
  end

  def resource_by_id; end

  def redirect_model_success(resource)
    resource.resource.iri(only_path: true).to_s
  end

  def resource_new_params
    {resource: parent_resource}
  end
end
