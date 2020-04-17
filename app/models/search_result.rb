# frozen_string_literal: true

class SearchResult < Collection
  include ActionDispatch::Routing
  include UriTemplateHelper
  include Rails.application.routes.url_helpers
  include Pundit
  include IRITemplateHelper
  include Cacheable

  attr_accessor :q

  delegate :aggs, :total_count, :took, to: :association_base

  def action_triples(*_args)
    []
  end

  def association_base
    @association_base ||= Result.new(self)
  end

  def filter_options
    Hash[aggs.map(&method(:filter_option_for_aggregate)).compact]
  end

  def filter_option_for_aggregate(key, value)
    return nil if value['buckets'].size <= 1

    datatype = association_class.predicate_mapping[RDF::URI(key)].datatype

    options = value['buckets'].map { |option| filter_options_for_bucket(option, datatype) }

    [RDF::URI(key), {values: options}]
  end

  def filter_options_for_bucket(option, datatype)
    {
      count: option['doc_count'],
      value: xsd_to_rdf(datatype, option['key_as_string'] || option['key'])
    }
  end

  def default_display
    :grid
  end

  def iri_opts
    opts = super
    opts[:q] = q if q.present?
    opts
  end

  def iri_template_keys
    super + %i[q]
  end

  def page_size
    @page_size&.to_i || 15
  end

  def sort_options
    [NS::ONTOLA[:relevance]] +
      (filtered_classes || [association_class])
        .map { |klass| klass.sort_options(self) }
        .reduce { |total, new| total & new }
        .flatten(1)
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

  def filtered_classes
    @filtered_classes ||=
      filters
        .detect { |filter| filter.key == NS::RDFV.type }
        &.value
        &.map { |type| association_class.descendants.detect { |klass| klass.iri.to_s == type } }
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
    delegate :aggs, :took, :total_count, to: :result

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
          published_branch: true
        }.merge(collection.filter)
      )
    end

    def unfiltered_collection
      @unfiltered_collection ||= new_child(filter: {}, q: q)
    end

    private

    def allowed_paths
      @allowed_paths ||= parent_granted? ? [parent.path] : granted_paths
    end

    def allowed_path_expression
      exp = allowed_paths
              .map { |p| "(#{Regexp.quote(p)}($|\\.[0-9]+)*)" }
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

      key
    end

    def sort_values
      Hash[sortings.select { |val| sort_key(val.key) }.map { |val| [sort_key(val.key), val.direction] }]
    end
  end
end
