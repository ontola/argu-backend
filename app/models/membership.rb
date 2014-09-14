class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :organisation

  enum role: {member: 0, moderator: 1, manager: 2}
end
