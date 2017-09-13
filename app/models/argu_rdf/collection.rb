# frozen_string_literal: true

module ArguRDF
  class Collection < Base
    include ::Collection::Mixin

    attr_accessor :resource,
                  :order,
                  :predicate

    def initialize(iri = nil, attributes = [], **opts)
      @iri = iri
      @id = opts[:id]
      @attributes = attributes
      @type = @attributes.find { |_, p, __| p == RDF.type } if @attributes
      super
    end

    def members
      return if include_pages? || filter?
      @members ||= association_base
                     .offset(offset)
                     .limit(limit)
    end

    def serializer_class
      RDFCollectionSerializer
    end

    def title
      'fds'
    end

    def uri(query_values = query_opts)
      base = if url_constructor.present?
               send(url_constructor, parent.id, protocol: :https)
             else
               url_for([parent, association_class, protocol: :https])
             end
      [base, query_values.to_param].reject(&:empty?).join('?')
    end

    private

    class RDFAssociation < Base
      include Enumerable
      attr_accessor :parent, :predicate

      def initialize(inst = nil, **opts)
        @attributes = []
        @_loaded = false
        @parent = inst&.parent || opts[:parent]
        @predicate = inst&.predicate || opts[:predicate]
        @_clauses = (inst&.clauses || [[parent.iri, predicate, :o]])
        @_clauses << opts[:clauses] if opts[:clauses]
        @_query ||= opts[:query]
      end

      def serializer_class
        nil
      end

      def count
        return @_count if @_count.present?
        q = client.select(count: {o: :c})
        clauses.each { |pq| q = q.where(pq) }
        @_count ||= q.execute[0][:c].to_i
      end

      def each
        _attrs.each do |i|
          yield attribute_for_serialization(i) if block_given?
        end
      end

      def limit(length)
        return self unless length
        RDFAssociation.new(self, query: query.limit(length))
      end

      def offset(start)
        return self unless start
        RDFAssociation.new(self, query: query.offset(start))
      end

      def where(*patterns_queries)
        return self unless patterns_queries
        RDFAssociation.new(
          self,
          clauses: patterns_queries
        )
      end

      protected

      def clauses
        @_clauses
      end

      private

      def _attrs
        unless @_loaded
          # limit to `association_class.instance_variable_get(:@_default_per_page)`
          # move class to outer pass
          solutions = query.execute
          @attributes = solutions.map(&:o)
          @_loaded = true
        end
        @attributes
      end

      def client
        @_client ||= SPARQL::Client.new('http://localhost:8898/marmotta/sparql/select')
      end

      def query
        return @_query if @_query
        q = client.select(:s, :p, :o)
        clauses.each { |pq| q = q.where(pq) }
        @_query = q
      end
    end

    def association_base
      @_ass ||= RDFAssociation.new(parent: parent, predicate: predicate)
    end

    def default_child_options
      super.merge(collection_class: self.class)
    end

    def filter?
      false
    end

    def offset
      return 0 if page.to_i.zero?
      (page.to_i.abs - 1) * association_class.default_per_page
    end

    def limit
      association_class.max_per_page
    end
  end
end
