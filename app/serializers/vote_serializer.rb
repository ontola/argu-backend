# frozen_string_literal: true
class VoteSerializer < BaseEdgeSerializer
  attributes :option

  def option
    case object.for
    when 'pro'
      'https://argu.co/ns/core#yes'
    when 'con'
      'https://argu.co/ns/core#no'
    else
      'https://argu.co/ns/core#other'
    end
  end

  has_one :voteable do
    obj = object.parent_model.voteable
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
end
