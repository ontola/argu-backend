# frozen_string_literal: true

class ActionSerializer < BaseSerializer
  def self.type(type = nil, &block)
    self._type = block || type
  end
  type(&:context_type)

  attribute :target, predicate: RDF::SCHEMA[:name]
  attribute :name, predicate: RDF::SCHEMA[:target]
end
