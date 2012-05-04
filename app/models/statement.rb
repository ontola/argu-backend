class Statement < ActiveRecord::Base
  has_many :statementarguments, :dependent => :destroy
  has_many :arguments, :through => :statementarguments

  before_save :trim_data
  before_save :cap_title

  has_restful_permissions

  attr_accessible :title, :content, :arguments, :statementarguments
 
  validates :content, presence: true, length: { minimum: 5, maximum: 140 }
  validates :title, presence: true, length: { minimum: 5, maximum: 50 }
  
  def creatable_by?(user)
    user.clearance <= Settings['permissions.create.statement']
  end
  def updatable_by?(user)
    user.clearance <= Settings['permissions.update.statement']
  end
  def destroyable_by?(user)
    user.clearance <= Settings['permissions.destroy.statement']
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
