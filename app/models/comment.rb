# frozen_string_literal: true

class Comment < Edge
  enhance ActivePublishable
  enhance Convertible

  include Edgeable::Content
  include TruncateHelper

  property :in_reply_to_id, :linked_edge_id, NS::ARGU[:inReplyTo], default: nil

  has_one :vote, primary_key_property: :comment_id, dependent: false
  belongs_to :parent_comment, foreign_key_property: :in_reply_to_id, class_name: 'Comment', dependent: false
  has_many :comments, primary_key_property: :in_reply_to_id, class_name: 'Comment', dependent: false
  has_many :active_comments,
           -> { active },
           primary_key_property: :in_reply_to_id,
           class_name: 'Comment',
           dependent: false
  belongs_to :commentable, polymorphic: true

  after_commit :set_vote, on: :create
  after_trash :unlink_vote

  counter_cache comments: {}, threads: {in_reply_to_id: nil}
  with_collection :comments, counter_cache_column: nil
  paginates_per 30
  parentable :pro_argument, :con_argument, :blog_post, :motion, :question, :linked_record, :topics,
             :risk, :intervention, :intervention_type, :measure, :measure_type

  validates :description, presence: true, allow_nil: false, length: {in: 4..5000}
  validates :creator, presence: true

  attr_accessor :is_processed, :vote_id

  def abandoned?
    is_trashed? && !has_children?
  end

  def joined_body
    [title, body].map(&:presence).compact.join("\n\n")
  end

  def deleted?
    body.blank? || body == '[DELETED]'
  end

  def subscribable
    parent_comment || parent
  end

  # helper method to check if a comment has children
  def has_children?
    comments.any?
  end

  def parent_collections(user_context)
    return super if parent_comment.blank?

    [parent_comment.comment_collection(user_context: user_context)]
  end

  def resource_added_delta
    [
      [parent.iri, NS::ARGU[:topComment], iri, NS::ONTOLA[:replace]]
    ]
  end

  def shallow_wipe
    if is_trashed?
      self.body = '[DELETED]'
      self.creator = nil
      self.is_processed = true
    end
    comments.each(&:shallow_wipe) if comments.present?
  end

  # Comments can't be deleted since all comments below would be hidden as well
  def wipe
    Comment.transaction do
      trash unless is_trashed?
      Comment.anonymize(Comment.where(id: id))
      unlink_vote
      update_attribute(:body, '') # rubocop:disable Rails/SkipsModelValidations
    end
  end

  private

  def set_vote
    return if vote_id.nil?
    vote = Edge.where_owner('Vote', creator: creator, uuid: vote_id, root_id: root_id).first ||
      raise(ActiveRecord::RecordNotFound)
    vote.update!(comment_id: uuid)
  end

  def unlink_vote
    vote&.update(comment_id: nil)
  end

  class << self
    def includes_for_serializer
      super.merge(comments: {}, vote: {})
    end

    def show_includes
      super + [
        comment_collection: inc_shallow_collection
      ]
    end
  end
end
