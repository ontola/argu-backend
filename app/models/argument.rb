class Argument < ActiveRecord::Base
  has_many :statementarguments
  has_many :statements, :through => :statementarguments

  attr_accessible :content, :title, :argtype, :statements

  validates :content, presence: true, length: { minimum: 5, maximum: 500 }
  validates :title, presence: true, length: { minimum: 5, maximum: 75 }
end
