# frozen_string_literal: true

class LinkedRecordSerializer < RecordSerializer
  include Argumentable::Serializer
  include Voteable::Serializer
  include Commentable::Serializer

  attribute :record_type, predicate: RDF::SCHEMA[:additionalType]

  link(:self) { object.iri if object.persisted? }
  link(:related) do
    {
      href: object.iri,
      meta: {
        predicate: RDF::SCHEMA[:isRelatedTo]
      }
    }
  end
end
