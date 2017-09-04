# frozen_string_literal: true

require 'test_helper'

class VoteEventsControllerTest < ActionController::TestCase
  define_freetown
  define_public_source
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown.edge) }
  let(:vote_event) { motion.default_vote_event }
  let(:linked_record) { create(:linked_record, :with_arguments, :with_votes, source: public_source) }
  let(:argument) { create(:argument, :with_comments, parent: motion.edge) }

  ####################################
  # Show
  ####################################
  test 'should get show vote_event' do
    get :show, params: {format: :json_api, id: vote_event.id}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('creator', 1)

    expect_relationship('voteCollection', 1)
    expect_included(argu_url("/vote_events/#{vote_event.id}/votes"))
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

  ####################################
  # Index for Motion
  ####################################
  test 'should get index vote_events of motion' do
    get :index, params: {format: :json_api, motion_id: motion.id}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('views', 0)
    expect_relationship('members', 1)

    expect_included(motion.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}") })
    expect_included(motion.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}/votes") })
    expect_included(motion.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}/votes", filter: {option: 'yes'}) })
    expect_included(
      motion.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}/votes", filter: {option: 'yes'}, page: 1) }
    )
    expect_included(motion.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}/votes", filter: {option: 'other'}) })
    expect_included(
      motion.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}/votes", filter: {option: 'other'}, page: 1) }
    )
    expect_included(motion.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}/votes", filter: {option: 'no'}) })
    expect_included(
      motion.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}/votes", filter: {option: 'no'}, page: 1) }
    )
    expect_included(
      vote_event.votes.joins(:creator).where(profiles: {are_votes_public: true}).map { |v| argu_url("/v/#{v.id}") }
    )
    expect_not_included(
      vote_event.votes.joins(:creator).where(profiles: {are_votes_public: false}).map { |v| argu_url("/v/#{v.id}") }
    )
  end

  ####################################
  # Index for LinkedRecord
  ####################################
  test 'should get index vote_events of linked_record' do
    get :index, params: {format: :json_api, linked_record_id: linked_record.id}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('views', 0)
    expect_relationship('members', 1)

    expect_included(linked_record.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}") })
    expect_included(linked_record.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}/votes") })
    expect_included(
      linked_record.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}/votes", filter: {option: 'yes'}) }
    )
    expect_included(
      linked_record.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}/votes", filter: {option: 'yes'}, page: 1) }
    )
    expect_included(
      linked_record.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}/votes", filter: {option: 'other'}) }
    )
    expect_included(
      linked_record.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}/votes", filter: {option: 'other'}, page: 1) }
    )
    expect_included(
      linked_record.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}/votes", filter: {option: 'no'}) }
    )
    expect_included(
      linked_record.vote_events.map { |ve| argu_url("/vote_events/#{ve.id}/votes", filter: {option: 'no'}, page: 1) }
    )
  end
end
