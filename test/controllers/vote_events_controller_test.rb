# frozen_string_literal: true

require 'test_helper'

class VoteEventsControllerTest < ActionController::TestCase
  define_freetown
  define_public_source
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown.edge) }
  let(:vote_event) { create(:vote_event, parent: motion.edge) }
  let(:linked_record) { create(:linked_record, :with_arguments, :with_votes, source: public_source) }
  let(:lr_vote_event) { linked_record.default_vote_event }
  let(:argument) { create(:argument, :with_comments, parent: motion.edge) }
  let!(:public_vote) { create(:vote, parent: vote_event.edge) }
  let!(:hidden_vote) do
    create(:vote, parent: vote_event.edge, creator: user_hidden_votes.profile, publisher: user_hidden_votes)
  end
  let(:user_hidden_votes) { create(:user, profile: build(:profile, are_votes_public: false)) }

  ####################################
  # VoteEvents of Motion
  ####################################
  test 'should get show vote_event of motion' do
    get :show, params: {format: :json_api, motion_id: motion.id, id: vote_event.id}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('creator', 1)

    expect_relationship('voteCollection', 1)
    expect_included(argu_url(vote_event_base_path(vote_event), type: 'paginated'))
    expect_included(argu_url(vote_event_base_path(vote_event), filter: {option: 'yes'}, type: 'paginated'))
    expect_included(argu_url(vote_event_base_path(vote_event), filter: {option: 'yes'}, page: 1, type: 'paginated'))
    expect_included(argu_url(vote_event_base_path(vote_event), filter: {option: 'other'}, type: 'paginated'))
    expect_included(argu_url(vote_event_base_path(vote_event), filter: {option: 'other'}, page: 1, type: 'paginated'))
    expect_included(argu_url(vote_event_base_path(vote_event), filter: {option: 'no'}, type: 'paginated'))
    expect_included(argu_url(vote_event_base_path(vote_event), filter: {option: 'no'}, page: 1, type: 'paginated'))
    expect_included(
      vote_event.votes.joins(:creator).where(profiles: {are_votes_public: true}).map { |v| argu_url("/v/#{v.id}") }
    )
    expect_not_included(
      vote_event.votes.joins(:creator).where(profiles: {are_votes_public: false}).map { |v| argu_url("/v/#{v.id}") }
    )
  end

  test 'should get show vote_event of motion with default id' do
    get :show, params: {format: :json_api, motion_id: motion.id, id: 'default'}
    assert_response 200

    assert_equal parsed_body['data']['id'], motion.default_vote_event.iri
    expect_relationship('parent', 1)
    expect_relationship('creator', 1)

    expect_relationship('voteCollection', 1)
    expect_included(argu_url(vote_event_base_path(motion.default_vote_event), type: 'paginated'))
  end

  test 'should get index vote_events of motion' do
    get :index, params: {format: :json_api, motion_id: motion.id}
    assert_response 200

    expect_relationship('parent', 1)
    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count, 2

    expect_included(motion.vote_events.map { |ve| argu_url("/m/#{motion.id}/vote_events/#{ve.id}") })
    expect_included(motion.vote_events.map { |ve| argu_url(vote_event_base_path(ve), type: 'paginated') })
    expect_included(
      motion
        .vote_events
        .map { |ve| argu_url(vote_event_base_path(ve), filter: {option: 'yes'}, type: 'paginated') }
    )
    expect_included(
      motion
        .vote_events
        .map { |ve| argu_url(vote_event_base_path(ve), filter: {option: 'yes'}, page: 1, type: 'paginated') }
    )
    expect_included(
      motion
        .vote_events
        .map { |ve| argu_url(vote_event_base_path(ve), filter: {option: 'other'}, type: 'paginated') }
    )
    expect_included(
      motion
        .vote_events
        .map { |ve| argu_url(vote_event_base_path(ve), filter: {option: 'other'}, page: 1, type: 'paginated') }
    )
    expect_included(
      motion
        .vote_events
        .map { |ve| argu_url(vote_event_base_path(ve), filter: {option: 'no'}, type: 'paginated') }
    )
    expect_included(
      motion
        .vote_events
        .map { |ve| argu_url(vote_event_base_path(ve), filter: {option: 'no'}, page: 1, type: 'paginated') }
    )
    expect_included(
      vote_event.votes.joins(:creator).where(profiles: {are_votes_public: true}).map { |v| argu_url("/v/#{v.id}") }
    )
    expect_not_included(
      vote_event.votes.joins(:creator).where(profiles: {are_votes_public: false}).map { |v| argu_url("/v/#{v.id}") }
    )
  end

  ####################################
  # VoteEvents for LinkedRecord
  ####################################
  test 'should get show vote_event of linked_record' do
    get :show, params: {format: :json_api, linked_record_id: linked_record.id, id: lr_vote_event.id}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('creator', 1)

    expect_relationship('voteCollection', 1)
    expect_included(argu_url(vote_event_base_path(lr_vote_event), type: 'paginated'))
    expect_included(argu_url(vote_event_base_path(lr_vote_event), filter: {option: 'yes'}, type: 'paginated'))
    expect_included(argu_url(vote_event_base_path(lr_vote_event), filter: {option: 'yes'}, page: 1, type: 'paginated'))
    expect_included(argu_url(vote_event_base_path(lr_vote_event), filter: {option: 'other'}, type: 'paginated'))
    expect_included(
      argu_url(vote_event_base_path(lr_vote_event), filter: {option: 'other'}, page: 1, type: 'paginated')
    )
    expect_included(argu_url(vote_event_base_path(lr_vote_event), filter: {option: 'no'}, type: 'paginated'))
    expect_included(argu_url(vote_event_base_path(lr_vote_event), filter: {option: 'no'}, page: 1, type: 'paginated'))
    expect_included(
      lr_vote_event.votes.joins(:creator).where(profiles: {are_votes_public: true}).map { |v| argu_url("/v/#{v.id}") }
    )
    expect_not_included(
      lr_vote_event.votes.joins(:creator).where(profiles: {are_votes_public: false}).map { |v| argu_url("/v/#{v.id}") }
    )
  end

  test 'should get show vote_event of linked_record with default id' do
    get :show, params: {format: :json_api, linked_record_id: linked_record.id, id: 'default'}
    assert_response 200

    assert_equal parsed_body['data']['id'], linked_record.default_vote_event.iri
    expect_relationship('parent', 1)
    expect_relationship('creator', 1)

    expect_relationship('voteCollection', 1)
    expect_included(argu_url(vote_event_base_path(linked_record.default_vote_event), type: 'paginated'))
  end

  test 'should get index vote_events of linked_record' do
    get :index, params: {format: :json_api, linked_record_id: linked_record.id}
    assert_response 200

    expect_relationship('parent', 1)
    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count, 1

    expect_included(linked_record.vote_events.map { |ve| argu_url("/lr/#{linked_record.id}/vote_events/#{ve.id}") })
    expect_included(linked_record.vote_events.map { |ve| argu_url(vote_event_base_path(ve), type: 'paginated') })
    expect_included(
      linked_record
        .vote_events
        .map { |ve| argu_url(vote_event_base_path(ve), filter: {option: 'yes'}, type: 'paginated') }
    )
    expect_included(
      linked_record
        .vote_events
        .map { |ve| argu_url(vote_event_base_path(ve), filter: {option: 'yes'}, page: 1, type: 'paginated') }
    )
    expect_included(
      linked_record
        .vote_events
        .map { |ve| argu_url(vote_event_base_path(ve), filter: {option: 'other'}, type: 'paginated') }
    )
    expect_included(
      linked_record
        .vote_events
        .map { |ve| argu_url(vote_event_base_path(ve), filter: {option: 'other'}, page: 1, type: 'paginated') }
    )
    expect_included(
      linked_record
        .vote_events
        .map { |ve| argu_url(vote_event_base_path(ve), filter: {option: 'no'}, type: 'paginated') }
    )
    expect_included(
      linked_record
        .vote_events
        .map { |ve| argu_url(vote_event_base_path(ve), filter: {option: 'no'}, page: 1, type: 'paginated') }
    )
  end

  private

  def vote_event_base_path(vote_event)
    case vote_event.voteable
    when Motion
      "/m/#{vote_event.voteable.id}/vote_events/#{vote_event.id}/v"
    when LinkedRecord
      "/lr/#{vote_event.voteable.id}/vote_events/#{vote_event.id}/v"
    end
  end
end
