# frozen_string_literal: true

class CommentsController < EdgeableController
  include UriTemplateHelper
  skip_before_action :check_if_registered, only: :index

  private

  def create_meta
    data = super
    if authenticated_resource.parent.enhanced_with?(Opinionable) && authenticated_resource.vote_id.present?
      voteable = authenticated_resource.parent
      data.concat(reset_potential_and_favorite_delta(voteable))
      data.concat(reset_potential_and_favorite_delta(voteable.comment_collection))
    end
    data
  end

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
