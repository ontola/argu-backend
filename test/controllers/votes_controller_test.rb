# frozen_string_literal: true

require 'test_helper'

class VotesControllerTest < ActionController::TestCase
  define_freetown
  define_public_source
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown.edge) }
  let(:argument) { motion.arguments.untrashed.first }
  let(:vote_event) { motion.default_vote_event }
  let(:vote) { motion.votes.first }
  let(:linked_record) { create(:linked_record, :with_arguments, :with_votes, source: public_source) }
  let(:user) { create(:user) }

  ####################################
  # Show
  ####################################
  test 'should get show vote' do
    get :show, params: {format: :json_api, id: vote.id}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('creator', 1)
  end

  ####################################
  # Create
  ####################################
  test 'should post create vote for argument as JS' do
    sign_in user
    post :create, params: {format: :js, argument_id: argument.id, for: 'pro'}
    assert_response 200
  end

  ####################################
  # Index for VoteEvent
  ####################################
  test 'should get index votes of vote_event' do
    get :index, params: {format: :json_api, vote_event_id: vote_event.id}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('members', 0)

    expect_relationship('views', 3)
    expect_included(argu_url("/vote_events/#{vote_event.id}/votes", filter: {option: 'yes'}))
    expect_included(argu_url("/vote_events/#{vote_event.id}/votes", filter: {option: 'yes'}, page: 1))
    expect_included(argu_url("/vote_events/#{vote_event.id}/votes", filter: {option: 'other'}))
    expect_included(argu_url("/vote_events/#{vote_event.id}/votes", filter: {option: 'other'}, page: 1))
    expect_included(argu_url("/vote_events/#{vote_event.id}/votes", filter: {option: 'no'}))
    expect_included(argu_url("/vote_events/#{vote_event.id}/votes", filter: {option: 'no'}, page: 1))
    expect_included(
      vote_event.votes.joins(:creator).where(profiles: {are_votes_public: true}).map { |v| argu_url("/v/#{v.id}") }
    )
    expect_not_included(
      vote_event.votes.joins(:creator).where(profiles: {are_votes_public: false}).map { |v| argu_url("/v/#{v.id}") }
    )
  end
end
