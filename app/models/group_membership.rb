class GroupMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group, inverse_of: :group_memberships

  counter_culture :group

  enum role: {member: 0, moderator: 1, manager: 2}
end
