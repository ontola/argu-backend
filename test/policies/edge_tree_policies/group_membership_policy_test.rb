# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class GroupMembershipPolicyTest < PolicyTest
  include DefaultPolicyTests
  let(:subject) { create(:group_membership, parent: create(:group, parent: page.edge), member: group_member.profile) }
  let(:group_member) { create(:user) }
  let(:admin_membership) { page.grants.super_admin.first.group.group_memberships.first }
  let(:second_admin_membership) { create(:group_membership, parent: page.grants.super_admin.first.group) }
  let(:subject_with_token) { create(:group_membership, parent: page.grants.super_admin.first.group, token: 'valid') }

  generate_crud_tests

  test 'should not destroy last admin group_membership' do
    test_policy(admin_membership, :destroy, staff: false)
  end

  test 'should destroy second admin group_membership' do
    test_policy(second_admin_membership, :destroy, staff: true)
  end

  test 'user should create with valid token' do
    validate_valid_bearer_token
    test_policy(subject_with_token, :create, user: true)
  end

  test 'user should not create with invalid token' do
    validate_invalid_bearer_token
    test_policy(subject_with_token, :create, user: false)
  end

  private

  def create_results
    nobody_results.merge(super_admin: true, staff: true)
  end

  def show_results
    nobody_results.merge(group_member: true)
  end

  def update_results
    staff_only_results
  end

  def destroy_results
    nobody_results.merge(group_member: true, super_admin: true, staff: true)
  end
end
