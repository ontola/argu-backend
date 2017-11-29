# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class SourcePolicyTest < PolicyTest
  include DefaultPolicyTests
  subject { public_source }
  let(:trashed_subject) { nil }
  let(:expired_subject) { nil }
  let(:unpublished_subject) { nil }
  let(:direct_child) { linked_record }

  generate_edgeable_tests

  alias create_results staff_only_results

  private

  def destroy_results
    nobody_results.merge(staff: true)
  end

  def trash_results
    nobody_results
  end

  def update_results
    nobody_results.merge(administrator: true, staff: true)
  end
end
