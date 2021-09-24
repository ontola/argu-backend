# frozen_string_literal: true

require 'test_helper'

class ProArgumentPolicyTest < Argu::TestHelpers::PolicyTest
  subject { pro_argument }
  let(:trashed_subject) { trashed_pro_argument }
  let(:expired_subject) { expired_pro_argument }
  let(:unpublished_subject) { unpublished_pro_argument }
  let(:direct_child) { comment }

  test 'edgeable policies pro argument' do
    test_edgeable_policies
  end
end
