# frozen_string_literal: true
require 'test_helper'

module Guest
  class VotesTest < ActionDispatch::IntegrationTest
    define_freetown
    let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown.edge) }
    let(:closed_question) { create(:question, edge_attributes: {expires_at: 1.day.ago}, parent: freetown.edge) }
    let(:closed_question_motion) { create(:motion, parent: closed_question.edge) }

    GUEST_HEADER = {headers: {'X-Allow-Guest': 'true'}.freeze}.freeze

    ####################################
    # Show
    ####################################
    test 'should not get show vote without guest header' do
      get root_path
      create_guest_vote(motion.default_vote_event.id, session.id)
      get motion_vote_path(motion.id, format: :json_api)
      assert_response 404
    end

    test 'should get show vote' do
      get root_path
      create_guest_vote(motion.default_vote_event.id, session.id)
      get motion_vote_path(motion.id, format: :json_api), **GUEST_HEADER
      assert_response 200

      expect_relationship('parent')
      creator = expect_relationship('creator')
      assert_equal creator.dig('data', 'id'), "https://127.0.0.1:42000/sessions/#{session.id}"
      assert_equal creator.dig('links', 'related', 'href'), "https://127.0.0.1:42000/sessions/#{session.id}"
    end

    test 'should not get show non-existent vote' do
      get root_path
      create_guest_vote(motion.default_vote_event.id, 'other_session_id')
      create_guest_vote('other_id', session.id)
      get motion_vote_path(motion.id, format: :json_api)
      assert_response 404
    end

    ####################################
    # Create
    ####################################
    test 'should post create vote for motion' do
      get root_path
      post motion_votes_path(motion.id, format: :json_api, vote: {for: :con}), **GUEST_HEADER
      assert_response 201
      get motion_vote_path(motion.id, format: :json_api), **GUEST_HEADER
      assert_response 200
    end

    test 'should post create vote for vote_event' do
      get root_path
      post vote_event_votes_path(motion.default_vote_event.id, format: :json_api, vote: {for: :con}), **GUEST_HEADER
      assert_response 201
      get motion_vote_path(motion.id, format: :json_api), **GUEST_HEADER
      assert_response 200
    end

    test 'should post update vote' do
      get root_path
      create_guest_vote(motion.default_vote_event.id, session.id)
      post motion_votes_path(motion.id, format: :json_api, vote: {for: :con}), **GUEST_HEADER
      assert_response 200
      get motion_vote_path(motion.id, format: :json_api), **GUEST_HEADER
      assert_response 200
    end

    test 'should post not create vote for closed motion' do
      get root_path
      post motion_votes_path(closed_question_motion.id, format: :json_api, vote: {for: :con}), **GUEST_HEADER
      assert_response 403
      get motion_vote_path(motion.id, format: :json_api), **GUEST_HEADER
      assert_response 404
    end
  end
end
