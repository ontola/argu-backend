# frozen_string_literal: true

class SearchResult
  class Query
    include Enumerable
    attr_accessor :collection

    delegate :default_search_filter, to: :association_class
    delegate :association_class, :page_size, :parent, :q, :sortings, :user_context, :views, to: :collection
    delegate :aggs, :took, :total_count, to: :result

    def initialize(collection)
      self.collection = collection
    end

    def each(&block)
      result.each(&block)
    end

    def edge_path
      parent.is_a?(LinkedRails.collection_class) ? parent.parent.path : parent.path
    end

    def page(*_args)
      self
    end

    def per(*_args)
      self
    end

    def result
      @result ||= association_class.search(
        q,
        aggs: parent.searchable_aggregations,
        match: match,
        order: sort_values,
        page: views.first.page,
        per_page: page_size,
        where: search_filter
      )
    end

    def unfiltered_collection
      @unfiltered_collection ||= new_child(filter: {}, match: match, q: q)
    end

    private

    def match
      :word_middle if collection.match.to_s == 'partial'
    end

    def search_filter
      @search_filter ||= default_search_filter(self).merge(collection.filter)
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
