# frozen_string_literal: true

class FavoritesController < AuthorizedController
  include NestedResourceHelper
  alias force_check_if_registered check_if_registered
  before_action :force_check_if_registered
  skip_after_action :verify_authorized, only: :destroy

  private

  def new_resource_from_params
    current_user.favorites.find_or_initialize_by(edge: parent_edge)
  end

  def parent_edge
    parent_resource&.edge
  end

  def redirect_url
    url_for(parent_resource)
  end

  def resource_by_id
    current_user.favorites.find_by(edge: parent_edge)
  end

  def respond_with_redirect_success(resource, action, opts = {})
    redirect_back fallback_location: root_path,
                  **opts.merge(notice: message_success(resource, action).capitalize)
  end

  def message_success(resource, action)
    if action == :destroy
      t('type_destroy_success', type: type_for(resource)).capitalize
    elsif action == :save
      t('type_create_success', type: type_for(resource)).capitalize
    end
  end

  def create_respond_failure_html
    flash[:error] = t('errors.general')
    redirect_back(fallback_location: root_path)
  end
  alias destroy_respond_failure_html create_respond_failure_html
end
