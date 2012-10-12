class Vote < ActiveRecord::Base
  belongs_to :statementargument, counter_cache: true
  has_one :user

  attr_accessible :statementargument_id, :user_id, :vote_type

end
