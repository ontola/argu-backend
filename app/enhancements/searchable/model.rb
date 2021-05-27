# frozen_string_literal: true

module Searchable
  module Model
    extend ActiveSupport::Concern

    included do
      include SerializationHelper

      searchkick callbacks: Rails.application.config.disable_searchkick ? false : :async,
                 index_name: lambda {
                   env = ENV['SEARCH_INDEX'] || Rails.env
                   "#{env}.#{table_name}.#{ActsAsTenant.current_tenant.uuid}"
                 },
                 inheritance: searchable_inheritance,
                 language: searchable_language,
                 settings: {
                   number_of_replicas: searchable_replicas,
                   number_of_shards: searchable_shards
                 },
                 word_middle: searchable_partial_fields

      def reindex(method_name = nil, **options)
        return if Rails.application.config.disable_searchkick

        ActsAsTenant.with_tenant(ActsAsTenant.current_tenant || root) do
          Searchkick::RecordIndexer.new(self).reindex(method_name, **options)
        end
      end

      def json_attributes
        serializable_resource(
          self,
          [:user]
        ).as_json['data']['attributes']
      end

      def rdf_attributes
        Hash[
          json_attributes.map do |key, value|
            predicate = self.class.predicate_for_key(key.to_s.underscore)
            [predicate.to_s, value] if predicate
          end.compact
        ]
      end
    end

    def search_data
      data = rdf_attributes
      data[:iri] = iri.to_s
      data[NS::ONTOLA[:primaryKey].to_s] = id
      data
    end

    def searchable_aggregations
      self.class.searchable_aggregations
    end

    def searchable_should_index?
      root_id == ActsAsTenant.current_tenant.root_id
    end

    def should_index?
      searchable_should_index?
    end

    module ClassMethods
      def default_search_filter(_query)
        {}
      end

      def searchable_aggregations
        nil
      end

      def searchable_inheritance
        true
      end

      # @see https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-stemmer-tokenfilter.html
      def searchable_language
        'dutch_kp'
      end

      def searchable_replicas
        ENV['SEARCH_REPLICAS'] || Rails.env.production? ? nil : 0
      end

      def searchable_shards
        ENV['SEARCH_SHARDS'] || Rails.env.production? ? nil : 1
      end

      def searchable_partial_fields
        [:iri, NS::SCHEMA.name]
      end
    end
  end
end
