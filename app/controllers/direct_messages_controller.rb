# frozen_string_literal: true

class DirectMessagesController < AuthorizedController
  include NestedResourceHelper

  def new
    authenticated_resource.email = current_user.email if current_user.confirmed?
    new_handler_success(authenticated_resource)
  end

  private

  def create_respond_success_html(resource)
    unless current_user.email_addresses.confirmed.where(email: resource.email).exists?
      raise Argu::NotAuthorizedError.new(record: resource, query: 'email?')
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
    @parent_resource ||=
      if parent_id_from_params(params).present?
        parent_from_params(params)
      else
        resource_from_iri(params[:direct_message][:resource_iri])
      end
  end

  def resource_by_id; end

  def redirect_model_success(resource)
    url_for([resource.resource, only_path: true])
  end

  def resource_new_params
    {resource: parent_resource}
  end
end
