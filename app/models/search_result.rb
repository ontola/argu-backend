# frozen_string_literal: true

class SearchResult
  include ActiveModel::Model
  include RailsLD::Model
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers
  include Pundit

  attr_accessor :page, :page_size, :parent, :q, :user_context
  delegate :user, :afe_request?, to: :user_context
  delegate :total_count, :took, to: :search_result

  alias read_attribute_for_serialization send

  def iri_opts
    opts = {}
    opts[:parent_iri] = parent&.iri_path if parent&.iri_path
    opts[:page] = page if page
    opts[:q] = q if q
    opts
  end

  def iri_path(_opts = {})
    super.gsub('%20', '+')
  end

  def first
    return nil if search_result.total_pages == 1
    RDF::DynamicURI(path_with_hostname(iri_path(page: nil)))
  end

  def last
    return nil if search_result.total_pages == 1
    RDF::DynamicURI(path_with_hostname(iri_path(page: search_result.total_pages)))
  end

  def prev
    return nil if search_result.total_pages == 1
    RDF::DynamicURI(path_with_hostname(iri_path(page: search_result.previous_page)))
  end

  def next
    return nil if search_result.total_pages == 1 || search_result.next_page.nil?
    RDF::DynamicURI(path_with_hostname(iri_path(page: search_result.next_page)))
  end

  def search_result
    @search_result ||= Edge.search(
      q,
      aggs: parent.searchable_aggregations,
      page: page,
      per_page: page_size || 15,
      where: {path: allowed_path_expression, published_branch: true}
    )
  end

  def results
    @results ||= RDF::Sequence.new(search_result)
  end

  private

  def allowed_paths
    @allowed_paths ||= parent_granted? ? [parent.path] : granted_paths
  end

  def allowed_path_expression
    exp = allowed_paths
            .map { |p| "(#{Regexp.quote(p)}[$|(\\.0-9+)]+)" }
            .join('|')
    Regexp.new(exp)
  end

  def granted_paths
    @granted_paths ||=
      user_context
        .grant_tree
        .grants_in_scope
        .select { |g| user_context.user.profile.group_ids.include?(g.group_id) }
        .map { |g| g.edge.path }
        .uniq
  end

  def parent_granted?
    granted_paths.any? { |p| p == parent.path || parent.path.starts_with?("#{p}.") }
  end
end