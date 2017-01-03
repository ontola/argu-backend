# frozen_string_literal: true
class LinkedRecordSerializer < RecordSerializer
  include Argumentable::Serlializer
  include Voteable::Serlializer

  link(:self) { object.context_id if object.persisted? }
  link(:related) do
    {
      href: object.iri,
      meta: {
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

  attributes :title, :record_type
end
