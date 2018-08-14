# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class ShortnamePolicyTest < PolicyTest
  include DefaultPolicyTests
  let(:subject) { create(:discussion_shortname, owner: motion, root_id: motion.root_id, primary: false) }
  let(:unscoped_subject) { create(:discussion_shortname, owner: motion, primary: false) }
  let(:primary_subject) { create(:discussion_shortname, owner: motion, root_id: motion.root_id) }

  generate_crud_tests

  test 'should create unscoped shortname' do
    test_policy(unscoped_subject, :create, staff_only_results)
  end

  test 'should not create primary shortname' do
    test_policy(primary_subject, :create, nobody_results)
  end

  test 'should not destroy primary shortname' do
    test_policy(primary_subject, :destroy, nobody_results)
  end

  # add tests

  private

  def create_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def destroy_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def show_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def update_results
    nobody_results.merge(administrator: true, staff: true)
  end
end
