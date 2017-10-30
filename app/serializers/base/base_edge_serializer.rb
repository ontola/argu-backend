# frozen_string_literal: true

class BaseEdgeSerializer < RecordSerializer
  attribute :display_name, key: :name, predicate: RDF::SCHEMA[:name]

  has_one :parent, predicate: RDF::SCHEMA[:isPartOf] do
    obj = object.parent_model
    link(:self) do
      {
        meta: {
          '@type': RDF::SCHEMA[:isPartOf]
        }
      }
    end
    link(:related) do
      href = obj.is_a?(LinkedRecord) ? obj.iri : obj.context_id
      type = obj.is_a?(LinkedRecord) ? obj.record_type : obj.class.try(:contextualized_type)
      {
        href: href,
        meta: {
          attributes: {
            '@id': href,
            '@type': type,
            '@context': {
              schema: 'http://schema.org/',
              title: 'schema:name'
            },
            title: obj.display_name
          }
        }
      }
    end
    obj
  end

  has_one :organization, predicate: RDF::SCHEMA[:organization] do
    obj = object.parent_model(:page)
    link(:self) do
      {
        meta: {
          '@type': RDF::SCHEMA[:organization]
        }
      }
    end
    link(:related) do
      href = obj.context_id
      {
        href: href,
        meta: {
          attributes: {
            '@id': href,
            '@type': obj.context_type,
            '@context': {
              schema: 'http://schema.org/',
              title: 'schema:name'
            },
            title: obj.display_name
          }
        }
      }
    end
    obj
  end

  has_one :creator, predicate: RDF::SCHEMA[:creator] do
    obj = object.creator.profileable
    link(:self) do
      {
        meta: {
          '@type': RDF::SCHEMA[:creator]
        }
      }
    end
    link(:related) do
      {
        href: obj.context_id,
        meta: {
          attributes: {
            '@context': {
              schema: 'http://schema.org/',
              name: 'schema:name'
            },
            '@type': obj.context_type,
            name: obj.display_name
          }
        }
      }
    end
    obj
  end
end
