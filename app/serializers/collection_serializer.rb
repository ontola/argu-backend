# frozen_string_literal: true

class CollectionSerializer < BaseSerializer
  attribute :title, predicate: RDF::SCHEMA[:name]
  attribute :total_count, predicate: RDF::ARGU[:totalCount]

  %i[first previous next last].each do |attr|
    link(attr) do
      {
        href: object.send(attr),
        meta: {
          '@type': "https://argu.co/ns/core##{attr}"
        }
      }
    end
  end

  link(:parent_view) do
    {
      href: object.parent_view_iri,
      meta: {
        '@type': RDF::ARGU[:parentView]
      }
    }
  end

  has_one :parent, predicate: RDF::SCHEMA[:isPartOf] do
    obj = object.parent
    if obj.present?
      link(:self) do
        {
          meta: {
            '@type': 'schema:isPartOf'
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
    end
    obj
  end

  has_one :create_action, predicate: RDF::ARGU[:createAction] do
    link(:self) do
      {
        href: object.create_action.id,
        meta: {
          '@type': 'argu:createAction'
        }
      }
    end
  end

  has_many :views, predicate: RDF::ARGU[:views] do
    link(:self) do
      {
        meta: {
          '@type': 'argu:views'
        }
      }
    end
  end

  has_many :members, predicate: RDF::ARGU[:members] do
    link(:self) do
      {
        meta: {
          '@type': 'argu:members'
        }
      }
    end
    if object.members.present?
      object.members.model_name == 'Edge' ? object.members.map(&:owner) : object.members
    end
  end
end
