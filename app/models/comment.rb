class Comment < ActiveRecord::Base
  include ArguBase, Parentable, Trashable, PublicActivity::Common, Mailable

  acts_as_nested_set :scope => [:commentable_id, :commentable_type]
  parentable :commentable
  mailable CommentMailer, :directly, :daily, :weekly

  after_save :creator_follow
  after_validation :increase_counter_cache, :touch_parent
  after_destroy :decrease_counter_cache

  validates_presence_of :profile
  validates :body, presence: true, length: {minimum: 4, maximum: 5000}

  attr_accessor :is_processed

  belongs_to :commentable, :polymorphic => true
  belongs_to :profile
  has_many :activities, as: :trackable, dependent: :destroy

  # Helper class method that allows you to build a comment
  # by passing a commentable object, a user_id, and comment text
  # example in readme
  def self.build_from(obj, profile_id, comment)
    c = self.new
    c.commentable_id = obj.id
    c.commentable_type = obj.class.base_class.name
    c.body = comment
    c.profile_id = profile_id
    c
  end

  def collect_recipients(type)
    profiles = Set.new
    if type == :directly
      profiles.merge commentable.parent.creator if comment.parent && comment.parent.creator.owner.direct_created_email?
    end
  end

  def creator
    self.profile
  end

  def creator_follow
    self.creator.follow self
  end

  def display_name
    self.body
  end

  #helper method to check if a comment has children
  def has_children?
    self.lft || self.rgt
  end

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  scope :find_comments_by_user, lambda { |user|
    where(:profile_id => user.profile.id).order('created_at DESC')
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

  def decrease_counter_cache
    self.commentable.decrement('comments_count').save
  end

  def increase_counter_cache
    self.commentable.increment('comments_count').save
  end

  def forum
    commentable.forum
  end

  # Comments can't be deleted since all comments below would be hidden as well
  def wipe
    self.update_columns profile_id: nil, body: nil
  end

end
