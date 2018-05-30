# frozen_string_literal: true

require 'test_helper'
require 'argu/test_helpers/policy_test'

class VotePolicyTest < PolicyTest
  include DefaultPolicyTests
  subject { vote }
  let(:trashed_subject) { trashed_vote }
  let(:expired_subject) { expired_vote }
  let(:unpublished_subject) { unpublished_vote }
  let(:direct_child) { nil }
  let(:hidden_vote) do
    create(:vote,
           parent: motion.default_vote_event,
           creator: user_hidden_votes.profile,
           publisher: user_hidden_votes)
  end
  let(:user_hidden_votes) { create(:user, profile: build(:profile, are_votes_public: false)) }

  generate_edgeable_tests

  test 'should hide hidden vote' do
    test_policy(hidden_vote, :show, staff_only_results.merge(user_hidden_votes: true))
  end

  private

  def update_results
    nobody_results.merge(creator: true)
  end

  def trash_results
    nobody_results
  end

  def destroy_results
    nobody_results.merge(creator: true)
  end
end
