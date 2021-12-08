# frozen_string_literal: true

class Motion < Discussion
  include ActionView::Helpers::NumberHelper

  enhance Argumentable
  enhance VoteEventable
  enhance Offerable

  include Edgeable::Content

  alias_attribute :content, :description
  alias_attribute :title, :display_name

  collection_options(
    call_to_action: -> { I18n.t('motions.call_to_action.title') }
  )
  convertible(
    questions: %i[activities media_objects],
    topics: %i[activities media_objects],
    comments: %i[activities]
  )
  paginates_per 10
  parentable :question, :container_node, :phase
  with_columns default: [
    NS.schema.name,
    NS.schema.creator,
    NS.argu.voteableVoteEvent
  ]

  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}
  validates :title, presence: true
  validates :creator, presence: true

  VOTE_OPTIONS = %i[yes other no].freeze unless defined?(VOTE_OPTIONS)

  def as_json(options = {})
    super((options || {}).merge(
      methods: %i[display_name],
      only: %i[id content forum_id created_at cover_photo updated_at]
    ))
  end

  def requires_location?
    parent.owner_type == 'Question' && parent.require_location
  end

  def upvote_only?
    parent.owner_type == 'Question' && parent.upvote_only?
  end

  class << self
    def order_by_predicate(predicate, direction)
      return super unless predicate == NS.argu[:votesProCount]

      Edge.order_child_count_sql(:votes_pro, as: 'default_vote_events_edges', direction: direction)
    end

    def route_key
      :m
    end

    def sort_options(collection)
      return super if collection.type == :infinite

      [NS.argu[:votesProCount], NS.schema.dateCreated, NS.argu[:lastActivityAt], NS.schema.name]
    end
  end
end
