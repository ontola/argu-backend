# frozen_string_literal: true

class Motion < Discussion
  include ActionView::Helpers::NumberHelper

  enhance Argumentable
  enhance Decisionable
  enhance Opinionable
  enhance VoteEventable

  include Edgeable::Content

  attr_accessor :current_vote

  alias_attribute :content, :description
  alias_attribute :title, :display_name

  convertible questions: %i[activities media_objects], comments: %i[activities]
  paginates_per 10
  parentable :question, :container_node, :phase

  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}
  validates :title, presence: true
  validates :creator, presence: true

  VOTE_OPTIONS = %i[pro neutral con].freeze unless defined?(VOTE_OPTIONS)

  def as_json(options = {})
    super((options || {}).merge(
      methods: %i[display_name],
      only: %i[id content forum_id created_at cover_photo updated_at]
    ))
  end

  def self.edge_includes_for_index(full = false)
    includes = super().deep_merge(default_vote_event: {}, last_published_decision: :properties)
    return includes unless full
    includes.deep_merge(
      attachments: {},
      creator: Profile.includes_for_profileable,
      top_comment: [vote: :properties, creator: Profile.includes_for_profileable],
      active_arguments: {}
    )
  end

  def self.order_by_predicate(predicate, direction)
    return super unless predicate == NS::ARGU[:votesProCount]
    Edge.order_child_count_sql(:votes_pro, as: 'default_vote_events_edges', direction: direction)
  end
end
