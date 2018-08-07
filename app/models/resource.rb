# frozen_string_literal: true

class Resource
  include ActiveModel::Serialization
  include ActiveModel::Model
  include RDF::Enumerable

  include ApplicationModel
  include Ldable
  include Iriable

  attr_accessor :iri
  alias_attribute :id, :iri
  alias_attribute :canonical_iri, :iri

  def initialize(attrs = {})
    super(attrs)
    @iri ||= RDF::Node.new
  end

  def statements
    [
      RDF::Statement(iri, NS::ARGU[:test], NS::ARGU[:duce])
    ]
  end

  def triples
    statements.map { |s| [s.subject, s.predicate, s.object] }
  end

  def self.for(iri)
    iri.is_a?(::RDF::Term) ? Resource.new(iri: iri) : iri
  end

  def self.iri
    NS::RDFS[:Resource]
  end
end
