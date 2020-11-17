# frozen_string_literal: true

class CommentsController < EdgeableController
  include UriTemplateHelper

  private

  def create_service_parent
    parent = super
    parent = parent.parent if parent.is_a?(Comment)
    parent
  end

  def redirect_location
    return super unless action_name == 'create' && authenticated_resource.persisted?

    authenticated_resource.parent.iri
  end

  def destroy_success_location
    authenticated_resource.parent.iri
  end

  def resource_new_params
    params = super
    params[:in_reply_to_id] = parent_resource.uuid if parent_resource.is_a?(Comment)
    params
  end
end
