# frozen_string_literal: true

class LinkedRecordSerializer < BaseSerializer
  attribute :same_as, predicate: RDF::OWL.sameAs do |object|
    object.external_iri
  end
  statements :external_statements

  def self.external_statements(object, _params)
    object.external_statements
  end
end
