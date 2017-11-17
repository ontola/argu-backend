# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class ForumPolicyTest < PolicyTest
  include DefaultPolicyTests
  subject { freetown }
  let(:trashed_subject) { nil }
  let(:expired_subject) { nil }
  let(:direct_child) { question }

  generate_edgeable_tests

  alias create_results staff_only_results

  private

  def destroy_results
    nobody_results.merge(super_admin: true, staff: true)
  end

  def update_results
    nobody_results.merge(super_admin: true, staff: true)
  end

  def invite_results
    nobody_results.merge(super_admin: true, staff: true)
  end
end