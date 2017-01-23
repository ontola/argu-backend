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

    assert_relationship('parent', 1)
    assert_relationship('creator', 1)

    assert_relationship('voteCollection', 1)
    assert_included("/vote_events/#{vote_event.id}/votes")
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

  ####################################
  # Index for Motion
  ####################################
  test 'should get index vote_events of motion' do
    get :index, params: {format: :json_api, motion_id: motion.id}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('views', 0)
    assert_relationship('members', 1)

    assert_included(motion.vote_events.map { |ve| "/vote_events/#{ve.id}" })
    assert_included(motion.vote_events.map { |ve| "/vote_events/#{ve.id}/votes" })
    assert_included(motion.vote_events.map { |ve| "/vote_events/#{ve.id}/votes?filter%5Boption%5D=yes" })
    assert_included(motion.vote_events.map { |ve| "/vote_events/#{ve.id}/votes?filter%5Boption%5D=yes&page=1" })
    assert_included(motion.vote_events.map { |ve| "/vote_events/#{ve.id}/votes?filter%5Boption%5D=other" })
    assert_included(motion.vote_events.map { |ve| "/vote_events/#{ve.id}/votes?filter%5Boption%5D=other&page=1" })
    assert_included(motion.vote_events.map { |ve| "/vote_events/#{ve.id}/votes?filter%5Boption%5D=no" })
    assert_included(motion.vote_events.map { |ve| "/vote_events/#{ve.id}/votes?filter%5Boption%5D=no&page=1" })
    assert_included(vote_event.votes.joins(:voter).where(profiles: {are_votes_public: true}).map { |v| "/v/#{v.id}" })
    assert_not_included(
      vote_event.votes.joins(:voter).where(profiles: {are_votes_public: false}).map { |v| "/v/#{v.id}" }
    )
  end

  ####################################
  # Index for LinkedRecord
  ####################################
  test 'should get index vote_events of linked_record' do
    get :index, params: {format: :json_api, linked_record_id: linked_record.id}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('views', 0)
    assert_relationship('members', 1)

    assert_included(linked_record.vote_events.map { |ve| "/vote_events/#{ve.id}" })
    assert_included(linked_record.vote_events.map { |ve| "/vote_events/#{ve.id}/votes" })
    assert_included(linked_record.vote_events.map { |ve| "/vote_events/#{ve.id}/votes?filter%5Boption%5D=yes" })
    assert_included(linked_record.vote_events.map { |ve| "/vote_events/#{ve.id}/votes?filter%5Boption%5D=yes&page=1" })
    assert_included(linked_record.vote_events.map { |ve| "/vote_events/#{ve.id}/votes?filter%5Boption%5D=other" })
    assert_included(
      linked_record.vote_events.map { |ve| "/vote_events/#{ve.id}/votes?filter%5Boption%5D=other&page=1" }
    )
    assert_included(linked_record.vote_events.map { |ve| "/vote_events/#{ve.id}/votes?filter%5Boption%5D=no" })
    assert_included(linked_record.vote_events.map { |ve| "/vote_events/#{ve.id}/votes?filter%5Boption%5D=no&page=1" })
  end
end
