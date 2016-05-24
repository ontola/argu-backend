class Opinion < ActiveRecord::Base
  include ArguBase, Parentable
  belongs_to :creator,
             class_name: 'Profile'
  belongs_to :forum
  belongs_to :motion
  belongs_to :publisher,
             class_name: 'User'
  has_many :opinion_arguments, dependent: :destroy
  has_many :arguments, through: :opinion_arguments

  enum for: {con: 0, pro: 1, neutral: 2, abstain: 3}
end
