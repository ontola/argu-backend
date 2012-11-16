class Vote < ActiveRecord::Base
  belongs_to :argument, counter_cache: true
  has_one :user

  attr_accessible :argument_id, :user_id, :vote_type

  scope :by_argument, lambda { |argument| { conditions: { :argument_id => argument } } }
end
