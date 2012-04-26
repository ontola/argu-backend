class Statement < ActiveRecord::Base
  has_many :statementarguments
  has_many :arguments, :through => :statementarguments

  attr_accessible :title, :content, :arguments, :statementarguments
 
  validates :content, presence: true, length: { minimum: 1, maximum: 140 }
  validates :title, presence: true, length: { minimum: 5, maximum: 50 }
  
end
