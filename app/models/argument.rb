# frozen_string_literal: true

class Argument < EdgeableBase
  VOTE_OPTIONS = [:pro].freeze unless defined?(VOTE_OPTIONS)

  concern Commentable
  include ContentEdgeable
  include HasLinks
  include VotesHelper

  has_many :votes, as: :voteable, dependent: :destroy

  before_save :capitalize_title

  validate :assert_tenant
  validates :content, presence: false, length: {maximum: 5000}
  validates :title, presence: true, length: {minimum: 5, maximum: 75}
  validates :creator, presence: true

  auto_strip_attributes :title, squish: true
  auto_strip_attributes :content
  counter_cache arguments_pro: {type: 'ProArgument'}, arguments_con: {type: 'ConArgument'}
  paginates_per 10
  parentable :motion, :linked_record
  with_collection :votes, pagination: true

  delegate :page, to: :forum
  attr_reader :pro
  alias_attribute :description, :content
  alias_attribute :display_name, :title
  alias default_vote_event_edge edge
  alias pro? pro

  def con?
    !pro?
  end

  def default_vote_event
    self
  end

  # @return [Argument, nil] The id of the next item or nil.
  def next(show_trashed = false)
    adjacent(false, show_trashed)
  end

  # @return [Argument, nil] The id of the previous item or nil.
  def previous(show_trashed = false)
    adjacent(true, show_trashed)
  end

  def pro=(value)
    value = false if %w[con false].include?(value)
    @pro = value.to_s == 'pro' || value
  end

  def remove_upvote(user, profile)
    service = DestroyVote.new(
      upvote_for(self, profile),
      options: {
        creator: profile,
        publisher: user
      }
    )
    service.on(:destroy_vote_failed) do
      raise 'Failed to remove upvote'
    end
    service.commit
  end

  def root_comments
    comment_threads.untrashed.where(parent_id: nil)
  end

  def upvote(user, profile)
    service = CreateVote.new(
      edge,
      attributes: {
        for: :pro,
        creator: profile
      },
      options: {
        creator: profile,
        publisher: user
      }
    )
    service.on(:create_vote_failed) do
      raise 'Failed to upvote'
    end
    service.commit
  end

  def voteable
    self
  end

  def self.ordered(pro_coll, con_coll, page = {})
    HashWithIndifferentAccess.new(
      pro: {
        collection: pro_coll.page(page[:pro] || 1) || [],
        page_param: :page_arg_pro
      },
      con: {
        collection: con_coll.page(page[:con] || 1) || [],
        page_param: :page_arg_con
      }
    )
  end

  private

  def adjacent(direction, _show_trashed = nil)
    return if is_trashed?
    ids = parent_model
            .arguments
            .untrashed
            .order("cast(edges.children_counts -> 'votes_pro' AS int) DESC NULLS LAST")
            .ids
    index = ids.index(self[:id])
    return nil if ids.length < 2
    p_id = ids[index.send(direction ? :- : :+, 1) % ids.count]
    parent_model.arguments.find_by(id: p_id)
  end

  def assert_tenant
    return if parent_model.is_a?(LinkedRecord) || forum == parent_model.forum
    errors.add(:forum, I18n.t('activerecord.errors.models.arguments.attributes.forum.different'))
  end
end
