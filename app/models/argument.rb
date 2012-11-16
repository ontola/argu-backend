include HasRestfulPermissions

class Argument < ActiveRecord::Base
  belongs_to :statement, :dependent => :destroy
  has_many :votes

  before_save :trim_data
  before_save :cap_title

  has_paper_trail
  acts_as_commentable

  attr_accessible :id, :content, :title, :argtype, :statement, :votes

  validates :content, presence: true, length: { minimum: 5, maximum: 500 }
  validates :title, presence: true, length: { minimum: 5, maximum: 75 }

  def trim_data
    self.title = title.strip
    self.content = content.strip
  end

  def cap_title 
    self.title = self.title.capitalize
  end

  def after_save
    self.update_counter_cache
  end

  def after_destroy
    self.update_counter_cache
  end

  def update_counter_cache
    self.statement.pro_count = self.statement.arguments.count(:conditions => ["pro = true"])
    self.statement.con_count = self.statement.arguments.count(:conditions => ["con = true"])
    self.statement.save
  end

  def voted_by?(user)
          !(self.votes.find_by_user_id(user.id).nil?) unless user.nil?
  end

  def get_vote(user)
          self.votes.find_by_user_id(user.id) unless user.nil?
  end

  def num_of_votes
          self.votes.count
  end

  scope :today, lambda { 
    {
      :conditions => ["created_at >= ?", (Time.now - 1.days)]
    }
  }
end
