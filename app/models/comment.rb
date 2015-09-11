class Comment < ActiveRecord::Base
  include ArguBase, Parentable, Trashable, PublicActivity::Common, Mailable

  acts_as_nested_set :scope => [:commentable_id, :commentable_type]
  parentable :commentable
  mailable CommentFollowerCollector, :directly, :daily, :weekly

  after_save :creator_follow
  after_validation :refresh_counter_cache, :touch_parent
  after_destroy :refresh_counter_cache

  validates_presence_of :creator
  validates :body, presence: true, length: {minimum: 4, maximum: 5000}

  attr_accessor :is_processed

  belongs_to :commentable, :polymorphic => true
  belongs_to :creator, class_name: 'Profile'
  has_many :activities, as: :trackable, dependent: :destroy

  def abandoned?
    self.is_trashed? && self.children.length == 0
  end

  # Helper class method that allows you to build a comment
  # by passing a commentable object, a user_id, and comment text
  # example in readme
  def self.build_from(obj, creator_id, comment)
    c = self.new
    c.commentable_id = obj.id
    c.commentable_type = obj.class.base_class.name
    c.body = comment
    c.creator_id = creator_id
    c
  end

  def creator_follow
    self.creator.follow self
  end

  def commentable_comments_count
    self.commentable.comment_threads
        .where(is_trashed: false)
        .where.not(creator_id: nil)
        .count
  end

  def display_name
    self.body
  end

  #helper method to check if a comment has children
  def has_children?
    self.lft || self.rgt
  end

  def is_wiped?
    self.is_trashed? && self.creator.nil? && self.body.blank?
  end

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  scope :find_comments_by_user, lambda { |user|
    where(:creator_id => user.profile.id).order('created_at DESC')
  }

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  scope :find_comments_for_commentable, lambda { |commentable_str, commentable_id|
    where(:commentable_type => commentable_str.to_s, :commentable_id => commentable_id).order('created_at DESC')
  }

  def touch_parent
    self.get_parent.model.touch
  end

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  def refresh_counter_cache
    self.commentable.update_columns comments_count: commentable_comments_count
  end

  # Comments can't be deleted since all comments below would be hidden as well
  def wipe
    success = false
    Comment.transaction do
      if self.update_columns creator_id: nil, body: '', is_trashed: true
        refresh_counter_cache
        self.activities.destroy_all
        success = true
      end
    end
    success
  end

end
