# frozen_string_literal: true

require 'test_helper'

class VotePolicyTest < Argu::TestHelpers::PolicyTest
  subject { vote }
  let(:trashed_subject) { trashed_vote }
  let(:expired_subject) { expired_vote }
  let(:unpublished_subject) { unpublished_vote }
  let(:hidden_vote) do
    create(:vote,
           parent: motion.default_vote_event,
           creator: user_hidden_votes.profile,
           publisher: user_hidden_votes)
  end
  let(:user_hidden_votes) { create(:user, show_feed: false) }

  test 'edgeable policies vote' do
    test_edgeable_policies
  end

  test 'should hide hidden vote' do
    test_policy(hidden_vote, :show, staff_only_results.merge(user_hidden_votes: true))
  end

  private

  def update_results
    nobody_results.merge(creator: true)
  end

  def feed_results
    nobody_results
  end

  def trash_results
    nobody_results
  end

  def destroy_results
    nobody_results.merge(creator: true)
  end
end
