# frozen_string_literal: true

module ArguRDF
  class RDFResource < Base
    include Kaminari::ConfigurationMethods
    include ArguRDF::PaginationMethods

    attr_accessor :resource

    def initialize(iri, attributes = [], **opts)
      @iri = iri
      @id = opts[:id]
      @attributes = attributes
      @type = @attributes.find { |_, p, __| p == RDF.type } if @attributes
    end

    def display_name
      plain_attribute attribute_in_resource?(RDF::Vocab::SCHEMA.name)
    end

    class << self
      # @param [String, RedisResource::Key] iri The iri of the resource to find.
      # @return [RDF::RDFResource] The found record
      def find(iri, **opts)
        sparql = SPARQL::Client.new('http://localhost:8898/marmotta/sparql/select')
        query = sparql.select(:s, :p, :o).where([iri, :p, :o])
        collections.map do |c|
          c_predicate = c[:options][:predicate]
          query = query.where([iri, "!<#{c_predicate}>", :o])
        end
        solutions = query.limit(1000).execute

        raise ActiveRecord::RecordNotFound.new if solutions.blank?

        attrs = solutions.map { |s| [iri, s.p, s.o] }
        new(iri, attrs, opts)
      end

      def find_by(**opts)
        id = opts.delete(:id)
        fsda
        raise NotImplementedError unless opts.blank?
        find(id)
      end
    end
  end
end
