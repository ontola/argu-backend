# frozen_string_literal: true

class SearchController < EdgeableController
  skip_before_action :check_if_registered, only: :index

  private

  def authorize_action
    authorize parent_resource!, :show?
  end

  def index_association
    skip_verify_policy_scoped(true)

    return search_result unless Rails.application.config.disable_searchkick

    Collection.new(
      association_base: Edge.none,
      association_class: Edge,
      parent_uri_template: :search_results_iri,
      parent_uri_template_canonical: :search_results_iri,
      title: ''
    )
  end

  def index_includes
    collection_includes.merge(results: {})
  end

  def search_result
    @search_result = SearchResult.new(
      {
        page: params[:page],
        parent: parent_resource,
        q: params[:q],
        user_context: user_context
      }.merge(collection_params)
    )
  end
end
