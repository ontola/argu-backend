# frozen_string_literal: true

require 'test_helper'
class GrantPolicyTest < Argu::TestHelpers::PolicyTest
  let(:subject) do
    create(:grant, edge: freetown, group: create(:group, parent: page), grant_set: GrantSet.participator)
  end
  let(:group_member) { create(:group_membership, parent: subject.group).member.profileable }

  test 'crud policies grant' do
    test_crud_policies
  end

  private

  def show_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def create_results
    nobody_results.merge(administrator: true, staff: true)
  end

  def update_results
    nobody_results.merge(staff: true)
  end

  def destroy_results
    nobody_results.merge(administrator: true, staff: true)
  end
end
