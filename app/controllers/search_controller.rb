# frozen_string_literal: true

class SearchController < EdgeableController
  skip_before_action :check_if_registered, only: :index

  private

  def authorize_action
    authorize parent_resource!, :show?
  end

  def index_collection
    @index_collection ||= ::SearchResult.new(
      collection_options.merge(
        parent: parent_resource,
        association_class: Edge,
        parent_uri_template: :search_results_iri,
        parent_uri_template_canonical: :search_results_iri,
        q: params[:q],
        title: ''
      )
    )
  end
end
