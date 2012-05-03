class Argument < ActiveRecord::Base
  has_many :statementarguments, :dependent => :destroy
  has_many :statements, :through => :statementarguments

  attr_accessible :id, :content, :title, :argtype, :statements

  validates :content, presence: true, length: { minimum: 5, maximum: 500 }
  validates :title, presence: true, length: { minimum: 5, maximum: 75 }

  scope :today, lambda { 
    {
      :conditions => ["created_at >= ?", (Time.now - 1.days)]
    }
  }
end
