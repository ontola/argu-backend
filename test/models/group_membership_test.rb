# frozen_string_literal: true
require 'test_helper'

class GroupMembershipTest < ActiveSupport::TestCase
  define_freetown
  subject { create(:group_membership, parent: group.edge, member: user.profile) }
  let(:group) { create(:group, parent: freetown.page.edge) }
  let(:user) { create(:user) }
  let(:manager) { create_manager(freetown) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
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

  test 'manager expire managership' do
    manager
    assert_difference('manager.reload.profile.grants.count', -1) do
      manager
        .profile
        .group_memberships
        .joins(:grants)
        .where(grants: {role: Grant.roles[:manager]})
        .first
        .update(end_date: DateTime.current)
    end
  end
end
