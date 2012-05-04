class Argument < ActiveRecord::Base
  has_many :statementarguments, :dependent => :destroy
  has_many :statements, :through => :statementarguments

  before_save :trim_data
  before_save :cap_title

  has_restful_permissions

  attr_accessible :id, :content, :title, :argtype, :statements

  validates :content, presence: true, length: { minimum: 5, maximum: 500 }
  validates :title, presence: true, length: { minimum: 5, maximum: 75 }

  def creatable_by?(user)
    user.clearance <= Settings['permissions.create.argument']
  end
  def updatable_by?(user)
    user.clearance <= Settings['permissions.update.argument']
  end
  def destroyable_by?(user)
    user.clearance <= Settings['permissions.destroy.argument']
  end

  def trim_data
    self.title = title.strip
    self.content = content.strip
  end

  def cap_title 
    self.title = self.title.capitalize
  end

  scope :today, lambda { 
    {
      :conditions => ["created_at >= ?", (Time.now - 1.days)]
    }
  }
end
