# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class DecisionPolicyTest < PolicyTest
  include DefaultPolicyTests
  subject { decision }
  let(:trashed_subject) { trashed_decision }
  let(:expired_subject) { expired_decision }
  let(:unpublished_subject) { unpublished_decision }
  let(:direct_child) { nil }

  let(:group) { create(:group, parent: argu.edge) }
  let(:forwarded_user) { create(:group_membership, parent: group).member.profileable }
  let(:forwarded_subject) do
    create(:decision,
           parent: motion.edge,
           publisher: creator,
           state: 'forwarded',
           forwarded_user_id: forwarded_user.id,
           forwarded_group_id: group.id,
           happening_attributes: {happened_at: Time.current})
  end
  let(:approve_forwarded_subject) do
    Decision.approved.new(edge: motion.edge.children.new(user: creator, parent: motion.edge))
  end

  generate_edgeable_tests

  alias create_results nobody_results
  alias destroy_results nobody_results
  alias feed_results nobody_results

  test 'create forward forwarded decision' do
    test_policy(forwarded_subject, :create, moderator_plus_results.merge(forwarded_user: true))
  end

  test 'create approve forwarded decision' do
    forwarded_subject
    test_policy(approve_forwarded_subject, :create, nobody_results.merge(forwarded_user: true))
  end

  private

  def trash_results
    nobody_results
  end
end
