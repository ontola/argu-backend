# frozen_string_literal: true

require 'test_helper'

class ConArgumentPolicyTest < Argu::TestHelpers::PolicyTest
  subject { con_argument }
  let(:trashed_subject) { trashed_con_argument }
  let(:expired_subject) { expired_con_argument }
  let(:unpublished_subject) { unpublished_con_argument }
  let(:direct_child) { con_argument_comment }

  test 'edgeable policies con argument' do
    test_edgeable_policies
  end
end
