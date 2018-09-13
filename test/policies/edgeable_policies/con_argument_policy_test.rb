# frozen_string_literal: true

require_relative 'argument_policy_test'

class ConArgumentPolicyTest < ArgumentPolicyTest
  subject { con_argument }
  let(:trashed_subject) { trashed_con_argument }
  let(:expired_subject) { expired_con_argument }
  let(:unpublished_subject) { unpublished_con_argument }
  let(:direct_child) { con_argument_comment }

  generate_edgeable_tests
end
