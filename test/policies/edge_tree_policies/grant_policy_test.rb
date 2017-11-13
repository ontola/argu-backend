# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class GrantPolicyTest < PolicyTest
  include DefaultPolicyTests
  let(:subject) { create(:grant, edge: freetown.edge, group: create(:group, parent: page.edge)) }
  let(:group_member) { create(:group_membership, parent: subject.group).member.profileable }

  generate_crud_tests

  private

  def show_results
    nobody_results.merge(super_admin: true, staff: true)
  end

  def create_results
    nobody_results.merge(super_admin: true, staff: true)
  end

  def update_results
    nobody_results.merge(staff: true)
  end

  def destroy_results
    nobody_results.merge(super_admin: true, staff: true)
  end
end
