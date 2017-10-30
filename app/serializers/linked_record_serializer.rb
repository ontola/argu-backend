# frozen_string_literal: true

class LinkedRecordSerializer < RecordSerializer
  include Argumentable::Serializer
  include Voteable::Serializer
  include Commentable::Serializer

  link(:self) { object.context_id if object.persisted? }
  link(:related) do
    {
      href: object.iri,
      meta: {
        '@type': RDF::SCHEMA[:isRelatedTo],
        attributes: {
          '@id': object.iri,
          '@type': object.record_type,
          '@context': {
            schema: 'http://schema.org/',
            title: 'schema:name'
          },
          title: object.display_name
        }
      }
    }
  end

  attribute :title, predicate: RDF::SCHEMA[:name]
  attribute :record_type
end
