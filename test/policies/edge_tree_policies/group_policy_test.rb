# frozen_string_literal: true

require 'test_helper'
class GroupPolicyTest < Argu::TestHelpers::PolicyTest
  let(:subject) { create(:group, parent: page) }
  let(:undeletable_subject) { create(:group, parent: page, deletable: false) }
  let(:group_member) { create(:group_membership, parent: subject).member.profileable }

  test 'crud policies group' do
    test_crud_policies
  end

  test 'should not destroy undeletable group' do
    test_policy(undeletable_subject, :destroy, staff: false)
  end

  private

  def create_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def update_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def destroy_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def show_results
    everybody_results
  end
end
