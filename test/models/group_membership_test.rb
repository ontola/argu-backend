require 'test_helper'

class GroupMembershipTest < ActiveSupport::TestCase
  define_freetown
  let(:user) { create(:user) }
  let(:user_membership) do
    create(:group_membership, parent: freetown.members_group.edge, member: user.profile)
  end
  let(:user_managership) do
    create(:group_membership, parent: freetown.managers_group.edge, member: user.profile)
  end
  let(:manager) { create_manager(freetown) }
  let(:member) { create_member(freetown) }
  let(:member_managership) do
    create(:group_membership, parent: freetown.managers_group.edge, member: member.profile)
  end
  subject { create(:group_membership, parent: freetown.members_group.edge, member: user.profile) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'user create membership' do
    user
    assert_difference('user.profile.grants.count', 1) do
      user_membership
    end
  end

  test 'user create membership before managership' do
    user
    assert_difference('user.profile.grants.count', 2) do
      user_managership
    end
  end

  test 'member create membership before managership' do
    member
    assert_difference('member.profile.grants.count', 1) do
      member_managership
    end
  end

  test 'manager destroy managership' do
    manager
    assert_difference('manager.profile.grants.count', -1) do
      manager
        .profile
        .group_memberships
        .joins(:grants)
        .where(grants: {role: Grant.roles[:manager]})
        .first
        .destroy
    end
  end

  test 'manager destroy managership on forum_leave' do
    manager
    assert_difference('manager.profile.grants.count', -2) do
      manager
        .profile
        .group_memberships
        .joins(:grants)
        .where(grants: {role: Grant.roles[:member]})
        .first
        .destroy
    end
  end
end
