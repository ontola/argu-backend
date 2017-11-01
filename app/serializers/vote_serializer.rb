# frozen_string_literal: true

class VoteSerializer < BaseEdgeSerializer
  attribute :option, predicate: RDF::SCHEMA[:option]
  attribute :explanation, predicate: RDF::SCHEMA[:text]
  attribute :explained_at

  has_one :voteable, predicate: RDF::SCHEMA[:isPartOf] do
    object.parent_model.voteable
  end

  has_many :upvoted_arguments, predicate: RDF::ARGU[:upvotedArguments]

  def option
    case object.for
    when 'pro'
      RDF::ARGU[:yes]
    when 'con'
      RDF::ARGU[:no]
    else
      RDF::ARGU[:other]
    end
  end
end
