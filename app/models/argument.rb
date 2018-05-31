# frozen_string_literal: true

class Argument < Edge
  VOTE_OPTIONS = [:pro].freeze unless defined?(VOTE_OPTIONS)

  concern Commentable
  include Edgeable::Content
  include HasLinks
  include VotesHelper

  before_save :capitalize_title

  validates :content, presence: false, length: {maximum: 5000}
  validates :title, presence: true, length: {minimum: 5, maximum: 75}
  validates :creator, presence: true

  auto_strip_attributes :title, squish: true
  auto_strip_attributes :content
  convertible comments: %i[activities]
  counter_cache arguments_pro: {owner_type: 'ProArgument'}, arguments_con: {owner_type: 'ConArgument'}
  paginates_per 10
  parentable :motion, :linked_record
  with_collection :votes, pagination: true

  attr_reader :pro
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

  def upvote(user, profile)
    service = CreateVote.new(
      self,
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
    ids = parent
            .arguments
            .untrashed
            .order("cast(edges.children_counts -> 'votes_pro' AS int) DESC NULLS LAST")
            .pluck(:uuid)
    index = ids.index(self[:uuid])
    return nil if ids.length < 2
    p_id = ids[index.send(direction ? :- : :+, 1) % ids.count]
    parent.arguments.find_by(uuid: p_id)
  end
end
