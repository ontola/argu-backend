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

  def resource_new_params # rubocop:disable Metrics/AbcSize
    new_params = super
    new_params[:in_reply_to_id] = parent_resource.uuid if parent_resource.is_a?(Comment)
    new_params[:pdf_page] = collection_params['filter'][NS::ARGU[:pdfPage]]&.first
    new_params[:pdf_position_x] = collection_params['filter'][NS::ARGU[:pdfPositionX]]&.first
    new_params[:pdf_position_y] = collection_params['filter'][NS::ARGU[:pdfPositionY]]&.first
    new_params
  end
end
