# frozen_string_literal: true

class VoteEvent < Edge
  enhance Votable

  counter_cache true
  parentable :motion
  property :starts_at, :datetime, NS.schema.startDate
  delegate :upvote_only?, to: :parent

  def display_name
    'Argu voting'
  end

  def to_param
    fragment || 'default'
  end

  def voteable
    parent
  end

  def options_vocab
    parent&.options_vocab
  end
end
