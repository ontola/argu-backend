# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class GrantPolicyTest < PolicyTest
  include DefaultPolicyTests
  let(:subject) { create(:grant, edge: freetown.edge, group: create(:group, parent: page.edge)) }

  generate_crud_tests

  private

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
