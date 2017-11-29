# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class PhasePolicyTest < PolicyTest
  include DefaultPolicyTests
  subject { phase }
  let(:trashed_subject) { trashed_phase }
  let(:expired_subject) { expired_phase }
  let(:unpublished_subject) { unpublished_phase }
  let(:direct_child) { nil }

  generate_edgeable_tests

  private

  def trash_results
    nobody_results
  end

  def create_results
    moderator_plus_results
  end

  def destroy_results
    moderator_plus_results
  end
end
