# frozen_string_literal: true

require 'test_helper'

class VoteEventsControllerTest < ActionController::TestCase
  define_freetown
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown.edge) }
  let(:vote_event) { create(:vote_event, parent: motion.edge) }
  let(:linked_record) { LinkedRecord.create_for_forum(freetown.page.url, freetown.url, SecureRandom.uuid) }
  let(:lr_vote_event) { linked_record.default_vote_event }
  let(:non_persisted_linked_record) { LinkedRecord.new_for_forum(freetown.page.url, freetown.url, SecureRandom.uuid) }
  let(:argument) { create(:argument, :with_comments, parent: motion.edge) }
  let!(:public_vote) { create(:vote, parent: vote_event.edge) }
  let!(:hidden_vote) do
    create(:vote, parent: vote_event.edge, creator: user_hidden_votes.profile, publisher: user_hidden_votes)
  end
  let!(:lr_public_vote) { create(:vote, parent: lr_vote_event.edge) }
  let!(:lr_hidden_vote) do
    create(:vote, parent: lr_vote_event.edge, creator: user_hidden_votes.profile, publisher: user_hidden_votes)
  end
  let(:user_hidden_votes) { create(:user, profile: build(:profile, are_votes_public: false)) }

  ####################################
  # VoteEvents of Motion
  ####################################
  test 'should get show vote_event of motion' do
    get :show, params: {format: :json_api, root_id: argu.id, motion_id: motion.id, id: vote_event.edge.fragment}
    assert_response 200

    expect_relationship('partOf', 1)
    expect_relationship('creator', 1)

    expect_relationship('voteCollection', 1)
    expect_included(collection_iri(vote_event, :votes, type: 'paginated'))
    %w[yes other no].each do |side|
      expect_included(collection_iri(vote_event, :votes, CGI.escape('filter[option]') => side, type: 'paginated'))
      expect_included(
        collection_iri(vote_event, :votes, CGI.escape('filter[option]') => side, page: 1, type: 'paginated')
      )
    end
    expect_included(vote_event.votes.joins(:creator).where(profiles: {are_votes_public: true}).map(&:iri))
    expect_not_included(vote_event.votes.joins(:creator).where(profiles: {are_votes_public: false}).map(&:iri))
  end

  test 'should get show vote_event of motion with default id' do
    get :show, params: {format: :json_api, root_id: argu.id, motion_id: motion.edge.fragment, id: 'default'}
    assert_response 200

    assert_equal parsed_body['data']['id'], motion.default_vote_event.iri
    expect_relationship('partOf', 1)
    expect_relationship('creator', 1)

    expect_relationship('voteCollection', 1)
    expect_included(collection_iri(motion.default_vote_event, :votes, type: 'paginated'))
  end

  test 'should get index vote_events of motion' do
    get :index, params: {format: :json_api, root_id: argu.id, motion_id: motion.edge.fragment}
    assert_response 200

    expect_relationship('partOf', 1)
    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count, 2

    expect_included(motion.vote_events.map(&:iri))
    expect_included(motion.vote_events.map { |ve| collection_iri(ve, :votes, type: 'paginated') })
    %w[yes other no].each do |side|
      expect_included(
        motion
          .vote_events
          .map { |ve| collection_iri(ve, :votes, CGI.escape('filter[option]') => side, type: 'paginated') }
      )
      expect_included(
        motion
          .vote_events
          .map { |ve| collection_iri(ve, :votes, CGI.escape('filter[option]') => side, page: 1, type: 'paginated') }
      )
    end
    expect_included(
      vote_event.votes.joins(:creator).where(profiles: {are_votes_public: true}).map(&:iri)
    )
    expect_not_included(
      vote_event.votes.joins(:creator).where(profiles: {are_votes_public: false}).map(&:iri)
    )
  end

  ####################################
  # VoteEvents for LinkedRecord
  ####################################
  test 'should get show vote_event of linked_record' do
    get :show,
        params: linked_record.iri_opts.merge(root_id: argu.id, id: lr_vote_event.edge.fragment, format: :json_api)
    assert_response 200

    expect_relationship('partOf', 1)
    expect_relationship('creator', 1)

    expect_relationship('voteCollection', 1)
    expect_included(collection_iri(lr_vote_event, :votes, type: 'paginated'))
    %w[yes other no].each do |side|
      expect_included(collection_iri(lr_vote_event, :votes, CGI.escape('filter[option]') => side, type: 'paginated'))
      expect_included(
        collection_iri(lr_vote_event, :votes, CGI.escape('filter[option]') => side, page: 1, type: 'paginated')
      )
    end
    expect_included(lr_vote_event.votes.joins(:creator).where(profiles: {are_votes_public: true}).map(&:iri))
    expect_not_included(lr_vote_event.votes.joins(:creator).where(profiles: {are_votes_public: false}).map(&:iri))
  end

  test 'should get show vote_event of linked_record with default id' do
    get :show, params: linked_record.iri_opts.merge(root_id: argu.id, id: 'default', format: :json_api)
    assert_response 200

    assert_equal parsed_body['data']['id'], lr_vote_event.iri
    expect_relationship('partOf', 1)
    expect_relationship('creator', 1)

    expect_relationship('voteCollection', 1)
    expect_included(collection_iri(lr_vote_event, :votes, type: 'paginated'))
  end

  test 'should get index vote_events of linked_record' do
    get :index, params: linked_record.iri_opts.merge(format: :json_api, root_id: argu.id)
    assert_response 200

    expect_relationship('partOf', 1)
    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count, 1

    expect_included(lr_vote_event.iri)
    expect_included(collection_iri(lr_vote_event, :votes, type: 'paginated'))
    %w[yes other no].each do |side|
      expect_included(collection_iri(lr_vote_event, :votes, CGI.escape('filter[option]') => side, type: 'paginated'))
      expect_included(
        collection_iri(lr_vote_event, :votes, CGI.escape('filter[option]') => side, page: 1, type: 'paginated')
      )
    end
  end

  ############################################
  # VoteEvents for non-persisted LinkedRecord
  ############################################
  test 'should get index vote_events of non-persisted linked_record' do
    get :index, params: non_persisted_linked_record.iri_opts.merge(format: :json_api, root_id: argu.url)
    assert_response 200

    expect_relationship('partOf', 1)

    assert_nil parsed_body.dig('data', 'relationships', 'memberSequence')
  end
end
