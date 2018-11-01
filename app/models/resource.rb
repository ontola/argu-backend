# frozen_string_literal: true

class Resource
  include ActiveModel::Serialization
  include ActiveModel::Model

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
end
