# frozen_string_literal: true

class FavoritesController < ParentableController
  alias force_check_if_registered check_if_registered
  before_action :force_check_if_registered
  skip_after_action :verify_authorized, only: :destroy

  private

  def new_resource_from_params
    current_user.favorites.find_or_initialize_by(edge: parent_resource!)
  end

  def parent_resource
    return super if params[:iri].blank?

    @parent_resource ||= resource_from_iri(params[:iri])&.ancestor(:forum) || super
  end

  def resource_by_id
    current_user.favorites.find_by(edge: parent_resource)
  end

  def redirect_location
    authenticated_resource.is_a?(Edge) ? authenticated_resource.iri : authenticated_resource.edge.iri
  end

  def active_response_success_message
    if action_name == :destroy
      t('type_destroy_success', type: type_for(authenticated_resource)).capitalize
    elsif action_name == :save
      t('type_create_success', type: type_for(authenticated_resource)).capitalize
    end
  end

  def create_failure_html(_resource)
    flash[:error] = t('errors.general')
    redirect_back(fallback_location: root_path)
  end
  alias destroy_failure_html create_failure_html
end
