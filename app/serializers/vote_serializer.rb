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
end
