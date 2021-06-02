# frozen_string_literal: true

class VoteEvent < Edge
  enhance Votable

  counter_cache true
  parentable :motion
  property :starts_at, :datetime, NS::SCHEMA[:startDate]
  delegate :upvote_only?, to: :parent

  def con_count
    children_count(:votes_con)
  end

  def display_name
    'Argu voting'
  end

  def iri_opts
    super.merge(id: to_param)
  end

  def neutral_count
    children_count(:votes_neutral)
  end

  def pro_count
    children_count(:votes_pro)
  end

  def to_param
    fragment || 'default'
  end

  def vote_collection_iri_opts
    iri_opts.slice(:vote_event_id, :motion_id)
  end

  def voteable
    parent
  end
end
