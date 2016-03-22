class Comment < ActiveRecord::Base
  include ArguBase, Parentable, Trashable, PublicActivity::Common

  acts_as_nested_set :scope => [:commentable_id, :commentable_type]
  acts_as_followable
  parentable :commentable

  belongs_to :forum
  belongs_to :commentable, :polymorphic => true
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'
  has_many :activities, as: :trackable
  has_many :subscribers, through: :followings, source: :follower, source_type: 'User'

  after_create :increment_counter_cache, :touch_parent
  validates_presence_of :creator
  validates :body, presence: true, allow_nil: false, length: {in: 4..5000}
  validates :forum, presence: true
  auto_strip_attributes :body

  attr_accessor :is_processed

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

  def abandoned?
    self.is_trashed? && self.children.length == 0
  end

  # Helper class method that allows you to build a comment
  # by passing a commentable object, a user_id, and comment text
  # example in readme
  def self.build_from(obj, profile_id, comment)
    c = self.new
    c.commentable_id = obj.id
    c.commentable_type = obj.class.base_class.name
    c.body = comment
    c.creator_id = profile_id
    c
  end

  def display_name
    self.body
  end

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  def subscribable
    self.parent || self.commentable
  end

  #helper method to check if a comment has children
  def has_children?
    self.lft || self.rgt
  end

  def touch_parent
    self.get_parent.model.touch
  end

  def increment_counter_cache
    self.commentable.increment!(:comments_count)
  end

  def decrement_counter_cache
    self.commentable.decrement!(:comments_count)
  end

  # Comments can't be deleted since all comments below would be hidden as well
  def wipe
    Comment.transaction do
      self.trash unless self.is_trashed?
      Comment.anonymize(Comment.where(id: self.id))
      self.update_column(:body, '')
    end
  end
end
