# frozen_string_literal: true

class LinkedRecordSerializer < RecordSerializer
  include Argumentable::Serializer
  include Voteable::Serializer
  include Commentable::Serializer

  attribute :record_type, predicate: RDF::SCHEMA[:additionalType]

  link(:self) { object.record_iri if object.persisted? }
  link(:related) do
    {
      href: object.record_iri,
      meta: {
        predicate: RDF::SCHEMA[:isRelatedTo]
      }
    }
  end
end
