# frozen_string_literal: true

class SearchController < EdgeableController
  skip_before_action :check_if_registered, only: :index
  after_action :set_cache_control_public, only: :index, if: :valid_blank_search?

  private

  def authorize_action
    authorize parent_resource!, :show?
  end

  def index_collection
    @index_collection ||= parent_resource.search_result(collection_options.merge(q: params[:q]))
  end

  def valid_blank_search?
    valid_response? && params[:q].blank?
  end
end
