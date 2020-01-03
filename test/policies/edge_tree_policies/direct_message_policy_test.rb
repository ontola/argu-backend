# frozen_string_literal: true

require 'test_helper'
class DirectMessagePolicyTest < Argu::TestHelpers::PolicyTest
  subject { DirectMessage.new(resource: motion) }

  test 'create valid direct_message' do
    test_policy(subject, :create, nobody_results.merge(staff: true, administrator: true))
  end
end
