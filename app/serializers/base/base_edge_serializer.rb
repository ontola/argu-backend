# frozen_string_literal: true
class BaseEdgeSerializer < RecordSerializer
  attribute :display_name, key: :name
  attributes :created_at, :updated_at

  has_one :parent do
    obj = object.parent_model
    link(:related) do
      {
        href: url_for(obj),
        meta: {
          '@type': 'schema:isPartOf',
          attributes: {
            '@id': obj.class.try(:context_id_factory)&.call(obj),
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
    link(:related) do
      {
        href: url_for(obj),
        meta: {
          '@type': 'schema:creator',
          attributes: {
            '@id': obj.class.try(:context_id_factory)&.call(obj),
            '@context': {
              schema: 'http://schema.org/',
              name: 'schema:name'
            },
            name: obj.display_name
          }
        }
      }
    end
    obj
  end
end
