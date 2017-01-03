# frozen_string_literal: true
class CollectionSerializer < BaseSerializer
  attributes :member, :title, :group_by

  has_one :parent do
    obj = object.parent
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
    obj
  end

  def member
    object.member.map do |i|
      h = i.respond_to?(:pro) ? {pro: i.pro} : {}
      h.merge(
        '@context': {
          pro: 'schema:option'
        },
        '@id': i.context_id
      )
    end
  end
end
