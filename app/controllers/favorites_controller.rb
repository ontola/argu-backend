# frozen_string_literal: true

class FavoritesController < ParentableController
  alias force_check_if_registered check_if_registered
  before_action :force_check_if_registered
  skip_after_action :verify_authorized, only: :destroy

  private

  def new_resource_from_params
    current_user.favorites.find_or_initialize_by(edge: parent_edge!)
  end

  def parent_resource
    resource_from_iri(params[:iri])&.parent_model(:forum) || super
  end

  def resource_by_id
    current_user.favorites.find_by(edge: parent_edge)
  end

  def redirect_model_success(resource)
    resource.edge.owner.iri(only_path: true).to_s
  end

  def message_success(resource, action)
    if action == :destroy
      t('type_destroy_success', type: type_for(resource)).capitalize
    elsif action == :save
      t('type_create_success', type: type_for(resource)).capitalize
    end
  end

  def create_respond_failure_html(_resource)
    flash[:error] = t('errors.general')
    redirect_back(fallback_location: root_path)
  end
  alias destroy_respond_failure_html create_respond_failure_html
end
