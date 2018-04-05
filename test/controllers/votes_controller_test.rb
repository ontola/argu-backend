# frozen_string_literal: true

require 'test_helper'

class VotesControllerTest < ActionController::TestCase
  define_freetown
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown.edge) }
  let(:argument) { motion.pro_arguments.untrashed.first }
  let(:vote_event) { motion.default_vote_event }
  let(:vote) { motion.votes.first }
  let(:linked_record) { LinkedRecord.create_for_forum(freetown.page.url, freetown.url, SecureRandom.uuid) }
  let(:user) { create(:user) }
  let(:vote_event_base_path) { "/m/#{motion.id}/vote_events/#{vote_event.id}/votes" }

  ####################################
  # Show
  ####################################
  test 'should get show vote' do
    get :show, params: {format: :json_api, id: vote.id}
    assert_response 200

    expect_relationship('partOf', 1)
    expect_relationship('creator', 1)
  end

  ####################################
  # Create
  ####################################
  test 'should post create vote for argument as JS' do
    sign_in user
    post :create, params: {format: :js, pro_argument_id: argument.id, for: 'pro'}
    assert_response 200
  end

  ####################################
  # Index for VoteEvent
  ####################################
  test 'should get index votes of vote_event' do
    get :index, params: {format: :json_api, motion_id: motion.id, vote_event_id: vote_event.id}
    assert_response 200

    expect_relationship('partOf', 1)

    view_sequence = expect_relationship('viewSequence')
    assert_equal expect_included(view_sequence['data']['id'])['relationships']['members']['data'].count, 3
    expect_included(argu_url(vote_event_base_path, filter: {option: 'yes'}, type: 'paginated'))
    expect_included(argu_url(vote_event_base_path, filter: {option: 'yes'}, page: 1, type: 'paginated'))
    expect_included(argu_url(vote_event_base_path, filter: {option: 'other'}, type: 'paginated'))
    expect_included(argu_url(vote_event_base_path, filter: {option: 'other'}, page: 1, type: 'paginated'))
    expect_included(argu_url(vote_event_base_path, filter: {option: 'no'}, type: 'paginated'))
    expect_included(argu_url(vote_event_base_path, filter: {option: 'no'}, page: 1, type: 'paginated'))
    expect_included(
      vote_event.votes.joins(:creator).where(profiles: {are_votes_public: true}).map { |v| argu_url("/votes/#{v.id}") }
    )
    expect_not_included(
      vote_event.votes.joins(:creator).where(profiles: {are_votes_public: false}).map { |v| argu_url("/votes/#{v.id}") }
    )
  end
end
