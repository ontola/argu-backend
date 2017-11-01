# frozen_string_literal: true

class ActionSerializer < BaseSerializer
  attribute :target, predicate: RDF::SCHEMA[:target]
  attribute :name, predicate: RDF::SCHEMA[:name]

  def type
    RDF::SCHEMA[object.type]
  end
end
