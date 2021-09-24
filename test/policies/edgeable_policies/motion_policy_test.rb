# frozen_string_literal: true

require 'test_helper'
class MotionPolicyTest < Argu::TestHelpers::PolicyTest
  subject { motion }
  let(:trashed_subject) { trashed_motion }
  let(:expired_subject) { expired_motion }
  let(:unpublished_subject) { unpublished_motion }
  let(:direct_child) { pro_argument }

  test 'edgeable policies motion' do
    test_edgeable_policies
  end

  test 'statistics motion' do
    test_policy(subject, :statistics, moderator_plus_results)
  end

  test 'create motion for forum' do
    test_policy(forum_motion, :create, create_results.merge(participator: false))
  end

  private

  alias move_results moderator_plus_results
  alias convert_results staff_only_results

  def invite_results
    nobody_results.merge(administrator: true, staff: true)
  end
end
