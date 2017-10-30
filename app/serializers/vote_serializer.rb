# frozen_string_literal: true

class VoteSerializer < BaseEdgeSerializer
  attribute :option, predicate: RDF::SCHEMA[:option]
  attribute :explanation, predicate: RDF::SCHEMA[:text]
  attribute :explained_at

  def option
    case object.for
    when 'pro'
      RDF::ARGU[RDF::ARGU[:yes]]
    when 'con'
      RDF::ARGU[:no]
    else
      RDF::ARGU[:other]
    end
  end

  has_one :voteable, predicate: RDF::SCHEMA[:isPartOf] do
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

  has_many :upvoted_arguments, predicate: RDF::ARGU[:upvotedArguments] do
    link(:self) do
      {
        meta: {
          '@type': 'argu:upvotedArguments'
        }
      }
    end
    object.upvoted_arguments
  end
end
