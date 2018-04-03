# frozen_string_literal: true

class Comment < Edgeable::Base
  include ContentEdgeable
  include TruncateHelper

  has_one :vote, dependent: :nullify
  after_commit :set_vote, on: :create

  acts_as_nested_set scope: %i[commentable_id commentable_type]
  counter_cache true
  paginates_per 30
  parentable :argument, :blog_post, :motion, :question, :linked_record

  validates :body, presence: true, allow_nil: false, length: {in: 4..5000}
  validates :creator, presence: true
  auto_strip_attributes :body

  attr_accessor :is_processed, :vote_id

  alias_attribute :content, :body

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  # @return [ActiveRecord::Relation]
  def self.find_comments_by_user(user)
    where(creator_id: user.profile.id).order('created_at DESC')
  end

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  # @return [ActiveRecord::Relation]
  def self.find_comments_for_commentable(commentable_str, commentable_id)
    where(commentable_type: commentable_str.to_s,
          commentable_id: commentable_id)
      .order('created_at DESC')
  end

  def abandoned?
    is_trashed? && children.length.zero?
  end

  # Helper class method that allows you to build a comment
  # by passing a commentable object, a user_id, and comment text
  # example in readme
  def self.build_from(obj, profile_id, comment)
    c = new
    c.commentable_id = obj.id
    c.commentable_type = obj.class.base_class.name
    c.body = comment
    c.creator_id = profile_id
    c
  end

  def deleted?
    body.blank? || body == '[DELETED]'
  end

  def display_name
    safe_truncated_text(body, 40)
  end

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  def subscribable
    parent || parent_model
  end

  # helper method to check if a comment has children
  def has_children?
    lft || rgt
  end

  def shallow_wipe
    if is_trashed?
      self.body = '[DELETED]'
      self.creator = nil
      self.is_processed = true
    end
    children.each(&:shallow_wipe) if children.present?
  end

  # Comments can't be deleted since all comments below would be hidden as well
  def wipe
    Comment.transaction do
      trash unless is_trashed?
      Comment.anonymize(Comment.where(id: id))
      update_column(:body, '')
    end
  end

  private

  def set_vote
    return if vote_id.nil?
    vote = Edge.where_owner('Vote', creator: creator, id: vote_id).first&.owner || raise(ActiveRecord::RecordNotFound)
    vote.update!(comment_id: id)
  end
end
