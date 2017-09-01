# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class ArgumentPolicyTest < PolicyTest
  include DefaultPolicyTests
  subject { argument }
  let(:trashed_subject) { trashed_argument }
  let(:expired_subject) { expired_argument }
  let(:direct_child) { comment }

  generate_edgeable_tests
end
