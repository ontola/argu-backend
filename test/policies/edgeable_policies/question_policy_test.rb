# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class QuestionPolicyTest < PolicyTest
  include DefaultPolicyTests
  subject { question }
  let(:trashed_subject) { trashed_question }
  let(:expired_subject) { expired_question }
  let(:unpublished_subject) { unpublished_question }
  let(:direct_child) { motion }

  generate_edgeable_tests

  private

  alias move_results staff_only_results
  alias convert_results staff_only_results

  def invite_results
    nobody_results.merge(administrator: true, staff: true)
  end
end
