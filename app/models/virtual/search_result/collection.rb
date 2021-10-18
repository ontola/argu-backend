# frozen_string_literal: true

class SearchResult
  class Collection < ::Collection
    attr_accessor :match, :q

    delegate :aggs, :total_count, :took, to: :association_base

    def action_triples
      []
    end

    def association_base
      @association_base ||= Query.new(self)
    end

    def cacheable?
      q.blank?
    end

    def filter_options
      Hash[aggs.map(&method(:filter_option_for_aggregate)).compact] if aggs
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
      opts[:match] = match if match.present?
      opts
    end

    def page_size
      @page_size&.to_i || 15
    end

    def sort_options
      [NS.ontola[:relevance]] +
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

    private

    def default_sortings
      [
        {
          direction: :desc,
          key: NS.ontola[:relevance]
        }
      ]
    end

    def filtered_classes
      @filtered_classes ||=
        filters
          .detect { |filter| filter.key == NS.rdfv.type }
          &.value
          &.map { |iri| class_by_iri(iri) }
    end

    def class_by_iri(iri)
      association_class.descendants.detect do |klass|
        iris = klass.iri.is_a?(Array) ? klass.iri : [klass.iri]
        iris.any? { |klass_iri| klass_iri.to_s == iri }
      end
    end

    class << self
      def collection_params(parser)
        options = parser.params.permit(:q, :match)

        super.merge(options)
      end

      def iri
        NS.ontola[:SearchResult]
      end
    end
  end
end
