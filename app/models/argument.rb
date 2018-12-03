# frozen_string_literal: true

class Argument < Edge
  VOTE_OPTIONS = [:pro].freeze unless defined?(VOTE_OPTIONS)

  enhance Createable
  enhance Commentable
  enhance Convertible
  enhance Contactable
  enhance Feedable
  enhance Statable

  include Edgeable::Content
  include HasLinks
  include VotesHelper

  before_save :capitalize_title

  validates :description, presence: false, length: {maximum: 5000}
  validates :display_name, presence: true, length: {minimum: 5, maximum: 75}
  validates :creator, presence: true

  auto_strip_attributes :title, squish: true
  auto_strip_attributes :content
  convertible comments: %i[activities]
  counter_cache true
  paginates_per 10
  parentable :motion, :linked_record
  with_collection :votes

  attr_reader :pro
  alias pro? pro

  def default_vote_event
    self
  end

  def self.includes_for_serializer
    super.merge(votes: {})
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
        collection:
          pro_coll.reorder(order_child_count_sql(:votes_pro)).order(:last_activity_at).page(page[:pro] || 1) || [],
        page_param: :page_arg_pro
      },
      con: {
        collection:
          con_coll.reorder(order_child_count_sql(:votes_pro)).order(:last_activity_at).page(page[:con] || 1) || [],
        page_param: :page_arg_con
      }
    )
  end

  private

  def adjacent(direction, _show_trashed = nil) # rubocop:disable Metrics/AbcSize
    return if is_trashed?
    ids = parent
            .arguments
            .untrashed
            .order(Edge.order_child_count_sql(:votes_pro))
            .pluck(:uuid)
    index = ids.index(self[:uuid])
    return nil if ids.length < 2
    p_id = ids[index.send(direction ? :- : :+, 1) % ids.count]
    parent.arguments.find_by(uuid: p_id)
  end
end
