# frozen_string_literal: true

class LinkedRecordSerializer < BaseSerializer
  attribute :same_as, predicate: NS::OWL.sameAs do |object|
    RDF::URI(object.external_iri)
  end
end
