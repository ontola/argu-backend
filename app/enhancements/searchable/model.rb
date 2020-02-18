# frozen_string_literal: true

module Searchable
  module Model
    extend ActiveSupport::Concern

    included do
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
                 }

      def searchable_aggregations
        nil
      end

      def searchable_should_index?
        true
      end

      def should_index?
        searchable_should_index?
      end
    end

    module ClassMethods
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
    end
  end
end
