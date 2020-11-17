# frozen_string_literal: true

class VoteEvent < Edge
  DEFAULT_ID = 'default'
  enhance LinkedRails::Enhancements::Actionable

  with_collection :votes

  counter_cache true
  parentable :motion
  property :starts_at, :datetime, NS::SCHEMA[:startDate]
  property :upvote_only, :boolean, NS::ARGU[:upvoteOnly]

  def con_count
    children_count(:votes_con)
  end

  def display_name
    'Argu voting'
  end

  def iri_opts
    super.merge(id: to_param, parent_iri: parent_iri_path)
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

  class << self
    def show_includes
      [
        vote_collection: inc_nested_collection
      ]
    end
  end
end
