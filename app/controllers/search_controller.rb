# frozen_string_literal: true

class SearchController < EdgeableController
  skip_before_action :check_if_registered, only: :index

  private

  def authorize_action
    authorize parent_resource!, :show?
  end

  def index_collection
    @index_collection ||= parent_resource.search_result(collection_options.merge(q: params[:q]))
  end
end
