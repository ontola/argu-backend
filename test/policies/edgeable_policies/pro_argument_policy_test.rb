# frozen_string_literal: true

require_relative 'argument_policy_test'

class ProArgumentPolicyTest < ArgumentPolicyTest
  subject { pro_argument }
  let(:trashed_subject) { trashed_pro_argument }
  let(:expired_subject) { expired_pro_argument }
  let(:unpublished_subject) { unpublished_pro_argument }
  let(:direct_child) { comment }

  generate_edgeable_tests
end
