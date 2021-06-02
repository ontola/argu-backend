# frozen_string_literal: true

require 'test_helper'
class VoteEventPolicyTest < Argu::TestHelpers::PolicyTest
  include Argu::TestHelpers::DefaultPolicyTests
  subject { vote_event }
  let(:trashed_subject) { trashed_vote_event }
  let(:expired_subject) { expired_vote_event }
  let(:unpublished_subject) { unpublished_vote_event }
  let(:direct_child) { vote }

  generate_edgeable_tests

  alias create_results nobody_results
  alias create_expired_results nobody_results
  alias create_trashed_results nobody_results
  alias update_results nobody_results
  alias trash_results nobody_results
  alias destroy_results nobody_results
  alias destroy_with_children_results nobody_results
  alias feed_results nobody_results
end
