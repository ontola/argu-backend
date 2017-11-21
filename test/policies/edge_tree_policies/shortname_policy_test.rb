# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class ShortnamePolicyTest < PolicyTest
  include DefaultPolicyTests
  let(:subject) { create(:discussion_shortname, forum: freetown, owner: motion) }

  generate_crud_tests

  test 'should create shortname when not depleted' do
    freetown.update(max_shortname_count: 2)
    test_policy(subject, :create, nobody_results.merge(administrator: true, staff: true))
  end

  private

  def create_results
    nobody_results
  end

  def destroy_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def update_results
    nobody_results.merge(administrator: true, staff: true)
  end
end
