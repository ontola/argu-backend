# frozen_string_literal: true
class BaseEdgeSerializer < RecordSerializer
  attribute :display_name, key: :name
  attributes :created_at, :updated_at

  has_one :parent do
    obj = object.parent_model
    link(:self) do
      {
        meta: {
          '@type': 'schema:isPartOf',
          attributes: {
            '@type': 'schema:isPartOf'
          }
        }
      }
    end
    link(:related) do
      {
        href: obj.context_id,
        meta: {
          attributes: {
            '@id': obj.context_id,
            '@type': obj.class.try(:contextualized_type),
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

  has_one :creator do
    obj = object.creator.profileable
    link(:self) do
      {
        meta: {
          '@type': 'schema:creator'
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
            '@type': 'schema:Person',
            name: obj.display_name
          }
        }
      }
    end
    obj
  end
end
