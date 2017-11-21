# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class MotionPolicyTest < PolicyTest
  include DefaultPolicyTests
  subject { motion }
  let(:trashed_subject) { trashed_motion }
  let(:expired_subject) { expired_motion }
  let(:direct_child) { argument }

  generate_edgeable_tests

  test 'statistics motion' do
    test_policy(subject, :statistics, moderator_plus_results)
  end

  private

  alias move_results staff_only_results
  alias convert_results staff_only_results

  def invite_results
    nobody_results.merge(administrator: true, staff: true)
  end
end
