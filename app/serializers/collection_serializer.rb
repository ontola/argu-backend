# frozen_string_literal: true
class CollectionSerializer < BaseSerializer
  attributes :title, :total_count

  link(:first) { object.first }
  link(:previous) { object.previous }
  link(:next) { object.next }
  link(:last) { object.last }

  has_one :parent do
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

  has_many :views do
    link(:self) do
      {
        meta: {
          '@type': 'argu:views'
        }
      }
    end
  end

  has_many :members do
    link(:self) do
      {
        meta: {
          '@type': 'argu:members'
        }
      }
    end
  end
end
