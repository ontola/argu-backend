# frozen_string_literal: true

class Comment < Edge
  include Edgeable::Content
  include TruncateHelper
  enhance Convertible

  property :in_reply_to_id, :linked_edge_id, NS::ARGU[:inReplyTo], default: nil

  has_one :vote, foreign_key_property: :comment_id, dependent: false
  belongs_to :parent_comment, foreign_key_property: :in_reply_to_id, class_name: 'Comment', dependent: false
  has_many :comment_children, foreign_key_property: :in_reply_to_id, class_name: 'Comment', dependent: false

  belongs_to :commentable, polymorphic: true

  after_commit :set_vote, on: :create

  counter_cache true
  paginates_per 30
  parentable :pro_argument, :con_argument, :blog_post, :motion, :question, :linked_record

  validates :body, presence: true, allow_nil: false, length: {in: 4..5000}
  validates :creator, presence: true
  auto_strip_attributes :body

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
    comment_children.any?
  end

  def shallow_wipe
    if is_trashed?
      self.body = '[DELETED]'
      self.creator = nil
      self.is_processed = true
    end
    comment_children.each(&:shallow_wipe) if comment_children.present?
  end

  # Comments can't be deleted since all comments below would be hidden as well
  def wipe
    Comment.transaction do
      trash unless is_trashed?
      Comment.anonymize(Comment.where(id: id))
      update_attribute(:body, '')
    end
  end

  private

  def set_vote
    return if vote_id.nil?
    vote = Edge.where_owner('Vote', creator: creator, uuid: vote_id, root_id: root_id).first ||
      raise(ActiveRecord::RecordNotFound)
    vote.update!(comment_id: uuid)
  end
end
