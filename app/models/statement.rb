class Statement < ActiveRecord::Base
  has_many :pros, class_name: 'Argument'
  has_many :cons, class_name: 'Argument'

  attr_accessible :title, :content, :pros, :cons
 
  validates :content, presence: true, length: { minimum: 1, maximum: 140 }
  validates :title, presence: true, length: { minimum: 5, maximum: 50 }
  
end
