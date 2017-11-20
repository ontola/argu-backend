# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class CommentPolicyTest < PolicyTest
  include DefaultPolicyTests
  subject { comment }
  let(:trashed_subject) { trashed_comment }
  let(:expired_subject) { expired_comment }
  let(:direct_child) { nested_comment }

  generate_edgeable_tests

  private

  alias destroy_with_children_results destroy_results

  def create_expired_results
    create_results
  end

  def update_results
    nobody_results.merge(creator: true)
  end
end
