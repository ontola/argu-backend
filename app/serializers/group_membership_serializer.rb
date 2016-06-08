class GroupMembershipSerializer < BaseSerializer
  has_one :group
  has_one :user
end
