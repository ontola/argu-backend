class Argument < ActiveRecord::Base
  belongs_to :statement

  attr_accessible :content, :type

  validates :content, presence: true, length: { minimum: 1, maximum: 140 } 
end
