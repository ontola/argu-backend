# frozen_string_literal: true

class CommentsController < EdgeableController
  include UriTemplateHelper
  skip_before_action :check_if_registered, only: :index

  private

  def create_meta
    data = super
    if authenticated_resource.parent.enhanced_with?(Opinionable) && authenticated_resource.vote_id.present?
      voteable = authenticated_resource.parent
      action_delta(data, :remove, voteable.comment_collection, :create_opinion, include_parent: true)
      action_delta(data, :add, voteable, :update_opinion)
    end
    data
  end

  def create_service_parent
    parent = super
    parent = parent.parent if parent.is_a?(Comment)
    parent
  end

  def redirect_location
    case authenticated_resource.parent
    when BlogPost, ProArgument, ConArgument
      authenticated_resource.parent.iri(fragment: authenticated_resource.identifier)
    else
      expand_uri_template(
        'comments_collection_iri',
        parent_iri: split_iri_segments(authenticated_resource.parent.iri.path),
        with_hostname: true
      )
    end
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
