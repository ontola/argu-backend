class Membership < ActiveRecord::Base
  belongs_to :profile
  belongs_to :organisation, inverse_of: :memberships

  counter_culture :organisation

  enum role: {member: 0, moderator: 1, manager: 2}
end
