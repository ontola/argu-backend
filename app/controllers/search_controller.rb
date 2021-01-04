# frozen_string_literal: true

class SearchController < EdgeableController
  ASSOCIATIONS = {
    groups: Group
  }.freeze

  skip_before_action :check_if_registered, only: :index
  after_action :set_cache_control_public, only: :index, if: :valid_blank_search?

  private

  def authorize_action
    authorize parent_resource!, :show?
  end

  def index_collection
    @index_collection ||= search_resource.search_result(
      collection_options.merge(
        match: params[:match],
        q: params[:q]
      )
    )
  end

  def search_resource
    uri = URI(request.original_url)
    uri.path = uri.path.split('.').first.chomp('/').chomp('/search')
    route_opts = LinkedRails.opts_from_iri(uri)
    klass = ASSOCIATIONS[route_opts[:controller]&.to_sym]
    klass&.root_collection || parent_resource
  end

  def valid_blank_search?
    valid_response? && params[:q].blank?
  end
end
