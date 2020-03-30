# frozen_string_literal: true

class SearchResult # rubocop:disable Metrics/ClassLength
  include ActiveModel::Model
  include LinkedRails::Model
  include ActionDispatch::Routing
  include UriTemplateHelper
  include Rails.application.routes.url_helpers
  include Pundit
  include IRITemplateHelper
  include Cacheable

  attr_accessor :filter, :page, :page_size, :parent, :q, :user_context
  attr_writer :sort
  delegate :user, to: :user_context
  delegate :total_count, :took, to: :search_result
  delegate :root, to: :parent

  def association_class
    Edge
  end

  def iri_opts
    opts = {}
    opts[:parent_iri] = split_iri_segments(parent&.iri_path) if parent&.iri_path
    opts[:page] = page if page
    opts[:q] = q if q
    opts['sort%5B%5D'] = sort_iri_opts if @sort
    opts
  end

  def first
    return nil if search_result.total_pages <= 1

    RDF::DynamicURI(path_with_hostname(iri_path(page: 1)))
  end

  def last
    return nil if search_result.total_pages <= 1

    RDF::DynamicURI(path_with_hostname(iri_path(page: search_result.total_pages)))
  end

  def name
    return I18n.t('search.placeholder') if q.blank?

    I18n.t('search.results_found', count: total_count)
  end

  def next
    return nil if search_result.total_pages <= 1 || search_result.next_page.nil?

    RDF::DynamicURI(path_with_hostname(iri_path(page: search_result.next_page)))
  end

  def prev
    return nil if search_result.total_pages <= 1

    RDF::DynamicURI(path_with_hostname(iri_path(page: search_result.previous_page)))
  end

  def results
    @results ||= LinkedRails::Sequence.new(search_result)
  end

  def route_key
    :search
  end

  def search_result
    @search_result ||= association_class.search(
      q,
      aggs: parent.searchable_aggregations,
      order: sort_values,
      page: page,
      per_page: page_size || 15,
      where: {
        path: allowed_path_expression,
        published_branch: true,
        trashed_at: nil
      }
    )
  end

  def search_template
    iri_template.to_s.gsub('{/parent_iri*}', parent&.iri || ActsAsTenant.current_tenant.iri)
  end

  def search_template_opts
    opts = iri_opts.with_indifferent_access.slice(:display, :'filter%5B%5D', :'sort%5B%5D', :page_size, :q, :type)
    Hash[opts.keys.map { |key| [CGI.escape(key), opts[key]] }].to_param
  end

  def sort_options
    [NS::ONTOLA[:relevance]] + association_class.sort_options(self)
  end

  def sortings
    @sortings ||= sort.map do |hash|
      CollectionSorting.new(
        association_class: association_class,
        direction: hash[:direction],
        key: hash[:key]
      )
    end
  end

  def type
    :paginated
  end

  def write_to_cache(cache = Argu::Cache.new)
    super
  rescue Searchkick::Error
    nil
  end

  private

  def allowed_paths
    @allowed_paths ||= parent_granted? ? [parent.path] : granted_paths
  end

  def allowed_path_expression
    exp = allowed_paths
            .map { |p| "(#{Regexp.quote(p)}[$|(\\.0-9+)]*)" }
            .join('|')
    Regexp.new("\\A#{exp}\\z")
  end

  def default_sortings
    [
      {
        direction: :asc,
        key: NS::ONTOLA[:relevance]
      }
    ]
  end

  def granted_paths # rubocop:disable Metrics/AbcSize
    return [] if user_context.blank?

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

  def sort
    @sort || default_sortings
  end

  def sort_iri_opts
    sort.map { |s| "#{CGI.escape(s[:key])}=#{s[:direction]}" }
  end

  def sort_key(key)
    return :_score if key == NS::ONTOLA[:relevance]

    association_class.predicate_mapping[key]&.name
  end

  def sort_values
    Hash[sort.map { |val| [sort_key(val[:key]), val[:direction]] }]
  end
end
