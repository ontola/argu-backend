include HasRestfulPermissions

class Statement < ActiveRecord::Base
  has_many :statementarguments, :dependent => :destroy, order: "votes_count DESC"
  has_many :arguments, :through => :statementarguments

  before_save :trim_data
  before_save :cap_title

  has_restful_permissions
  has_paper_trail

  attr_accessible :id, :title, :content, :arguments, :statementarguments, :statetype
 
  validates :content, presence: true, length: { minimum: 5, maximum: 140 }
  validates :title, presence: true, length: { minimum: 5, maximum: 50 }

  class << self
    def creatable_by?(user)
      Settings['permissions.create.statement'] >= user.clearance unless user.clearance.nil?
    end
  end
  def updatable_by?(user)
    Settings['permissions.update.statement'] >= user.clearance unless user.clearance.nil?
  end
  def destroyable_by?(user)
    Settings['permissions.destroy.statement'] >= user.clearance unless user.clearance.nil?
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
