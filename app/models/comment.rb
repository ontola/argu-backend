class Comment < ActiveRecord::Base
  acts_as_nested_set :scope => [:commentable_id, :commentable_type]

  after_validation :increase_counter_cache
  after_destroy :decrease_counter_cache

  validates_presence_of :profile
  validates :body, presence: true, minimum: 4

  belongs_to :commentable, :polymorphic => true
  belongs_to :profile

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

  def creator
    self.profile
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

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  def decrease_counter_cache
    self.commentable.decrement("comments_count").save
  end
  def increase_counter_cache
    self.commentable.increment("comments_count").save
  end

  def is_trashed?
    read_attribute :is_trashed
  end
  def trash
    update_attribute :is_trashed, true
  end
end
