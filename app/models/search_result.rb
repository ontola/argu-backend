# frozen_string_literal: true

class SearchResult < Collection
  include ActionDispatch::Routing
  include UriTemplateHelper
  include Rails.application.routes.url_helpers
  include Pundit
  include IRITemplateHelper
  include Cacheable

  attr_accessor :q

  delegate :total_count, :took, to: :association_base

  def action_triples(*_args)
    []
  end

  def association_base
    @association_base ||= Result.new(self)
  end

  def default_display
    :grid
  end

  def iri_opts
    opts = super
    opts[:q] = q if q.present?
    opts
  end

  def iri_template_opts
    opts = iri_opts.with_indifferent_access.slice(:display, :'filter%5B%5D', :'sort%5B%5D', :page_size, :q, :type)
    Hash[opts.keys.map { |key| [CGI.unescape(key), opts[key]] }].to_param
  end

  def page_size
    @page_size&.to_i || 15
  end

  def sort_options
    [NS::ONTOLA[:relevance]] + association_class.sort_options(self)
  end

  def sortings
    super
  end

  def placeholder(locale = nil)
    I18n.t('search.placeholder', locale: locale)
  end

  def title
    return I18n.t('search.results_found', count: total_count) if q.present?

    I18n.available_locales.map do |locale|
      RDF::Literal(placeholder(locale), language: locale)
    end
  end

  def write_to_cache(cache = Argu::Cache.new)
    super
  rescue Searchkick::Error
    nil
  end

  private

  def default_sortings
    [
      {
        direction: :desc,
        key: NS::ONTOLA[:relevance]
      }
    ]
  end

  class << self
    def iri
      NS::ONTOLA[:SearchResult]
    end
  end

  class Result
    include Enumerable
    attr_accessor :collection

    delegate :association_class, :page_size, :parent, :q, :sortings, :user_context, :views, to: :collection
    delegate :took, :total_count, to: :result

    def initialize(collection)
      self.collection = collection
    end

    def each(&block)
      result.each(&block)
    end

    def page(*_args)
      self
    end

    def per(*_args)
      self
    end

    def result # rubocop:disable Metrics/MethodLength
      @result ||= association_class.search(
        q,
        aggs: parent.searchable_aggregations,
        order: sort_values,
        page: views.first.page,
        per_page: page_size,
        where: {
          path: allowed_path_expression,
          published_branch: true,
          trashed_at: nil
        }
      )
    end

    def unfiltered_collection
      @unfiltered_collection ||= new_child(filter: [], q: q)
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

    def sort_key(key)
      return :_score if key == NS::ONTOLA[:relevance]

      association_class.predicate_mapping[key]&.name
    end

    def sort_values
      Hash[sortings.select { |val| sort_key(val.key) }.map { |val| [sort_key(val.key), val.direction] }]
    end
  end
end
