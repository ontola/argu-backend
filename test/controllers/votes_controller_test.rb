# frozen_string_literal: true
require 'test_helper'

class VotesControllerTest < ActionController::TestCase
  define_freetown
  define_public_source
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown.edge) }
  let(:vote_event) { motion.default_vote_event }
  let(:vote) { motion.votes.first }
  let(:linked_record) { create(:linked_record, :with_arguments, :with_votes, source: public_source) }

  ####################################
  # Show
  ####################################
  test 'should get show vote' do
    get :show, params: {format: :json_api, id: vote.id}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('creator', 1)
  end

  ####################################
  # Index for VoteEvent
  ####################################
  test 'should get index votes of vote_event' do
    get :index, params: {format: :json_api, vote_event_id: vote_event.id}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('members', 0)

    assert_relationship('views', 3)
    assert_included("/vote_events/#{vote_event.id}/votes?filter%5Boption%5D=yes")
    assert_included("/vote_events/#{vote_event.id}/votes?filter%5Boption%5D=yes&page=1")
    assert_included("/vote_events/#{vote_event.id}/votes?filter%5Boption%5D=other")
    assert_included("/vote_events/#{vote_event.id}/votes?filter%5Boption%5D=other&page=1")
    assert_included("/vote_events/#{vote_event.id}/votes?filter%5Boption%5D=no")
    assert_included("/vote_events/#{vote_event.id}/votes?filter%5Boption%5D=no&page=1")
    assert_included(vote_event.votes.joins(:voter).where(profiles: {are_votes_public: true}).map { |v| "/v/#{v.id}" })
    assert_not_included(
      vote_event.votes.joins(:voter).where(profiles: {are_votes_public: false}).map { |v| "/v/#{v.id}" }
    )
  end
end
