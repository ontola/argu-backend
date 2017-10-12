# frozen_string_literal: true

require 'test_helper'

class GroupMembershipTest < ActiveSupport::TestCase
  define_freetown
  subject { create(:group_membership, parent: custom_group, member: user.profile) }
  let(:second_record) { create(:group_membership, parent: custom_group, member: manager.profile) }
  let(:custom_group) { create(:group, parent: freetown.page.edge) }
  let(:second_group) { create(:group, parent: freetown.page.edge) }
  let(:user) { create(:user) }
  let(:manager) { create_manager(freetown) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'membership for comminuty profile is invalid' do
    assert_not GroupMembership.new(group: custom_group, member: Profile.community, start_date: DateTime.current).valid?
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

  test 'validation allows no overlapping group_memberships' do
    subject.update(end_date: 2.days.from_now)

    # can create outside member/group scope
    assert create_group_membership(member: manager.profile), @errors
    assert create_group_membership(group: second_group), @errors

    # cannot create before or during existing membership
    assert_not create_group_membership
    assert_not create_group_membership(start_date: DateTime.current, end_date: 4.days.from_now)
    assert_not create_group_membership(start_date: DateTime.current)
    subject.update(end_date: nil)
    assert_not create_group_membership
    assert_not create_group_membership(start_date: 3.days.from_now)
    assert_not create_group_membership(start_date: 3.days.from_now, end_date: 4.days.from_now)
    assert_not create_group_membership(start_date: 2.days.ago)

    # can create before existing membership
    assert create_group_membership(start_date: 2.days.ago, end_date: 1.day.ago), @errors

    # can create after existing membership
    subject.update(end_date: 2.days.from_now)
    assert create_group_membership(start_date: 3.days.from_now, end_date: 4.days.from_now), @errors
  end

  test 'constraint allows no partial overlapping group_memberships' do
    subject.update(end_date: 2.days.from_now)
    assert_raises(ActiveRecord::StatementInvalid) do
      second_record.update_columns(member_id: user.profile.id, start_date: DateTime.current, end_date: nil)
    end
  end

  test 'constraint allows no completely overlapping group_memberships' do
    subject.update(end_date: 2.days.from_now)
    assert_raises(ActiveRecord::StatementInvalid) do
      second_record.update_columns(member_id: user.profile.id, start_date: 1.day.ago, end_date: 4.days.from_now)
    end
  end

  private

  def create_group_membership(member: user.profile, group: custom_group, start_date: DateTime.current, end_date: nil)
    gm = GroupMembership
      .create(
        group_id: group.id,
        member_id: member.id,
        start_date: start_date,
        end_date: end_date
      )
    @errors = gm.errors.full_messages
    gm.valid?
  end
end
