# frozen_string_literal: true
class VoteSerializer < BaseEdgeSerializer
  attributes :option

  def option
    case object.for
    when 'pro'
      'http://schema.org/yes'
    when 'con'
      'http://schema.org/no'
    else
      'http://schema.org/neutral'
    end
  end
end
