# frozen_string_literal: true
require 'test_helper'

module Guest
  class VotesControllerTest < ActionController::TestCase
    define_freetown
    let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown.edge) }
    let(:closed_question) { create(:question, edge_attributes: {expires_at: 1.day.ago}, parent: freetown.edge) }
    let(:closed_question_motion) { create(:motion, parent: closed_question.edge) }

    ####################################
    # Show
    ####################################
    test 'should get show vote' do
      Argu::Redis.set(key(motion.id, session.id), {for: :pro, created_at: DateTime.current, id: 1}.to_json)
      get :show, params: {format: :json_api, motion_id: motion.id}
      assert_response 200

      assert_relationship('parent')
      creator = assert_relationship('creator')
      assert_equal creator.dig('data', 'id'), "https://127.0.0.1:42000/sessions/#{session.id}"
      assert_equal creator.dig('links', 'related', 'href'), "https://127.0.0.1:42000/sessions/#{session.id}"
    end

    test 'should not get show non-existent vote' do
      Argu::Redis.set(key(motion.id, 'other_session_id'), {for: :pro, created_at: DateTime.current, id: 1}.to_json)
      Argu::Redis.set(key('other_motion_id', session.id), {for: :pro, created_at: DateTime.current, id: 2}.to_json)
      get :show, params: {format: :json_api, motion_id: motion.id}
      assert_response 404
    end

    ####################################
    # Create
    ####################################
    test 'should post create vote' do
      post :create, params: {format: :json_api, motion_id: motion.id, vote: {for: :con}}
      assert_response 201
      get :show, params: {format: :json_api, motion_id: motion.id}
      assert_response 200
    end

    test 'should post update vote' do
      Argu::Redis.set(key(motion.id, session.id), {for: :pro, created_at: DateTime.current, id: 1}.to_json)
      post :create, params: {format: :json_api, motion_id: motion.id, vote: {for: :con}}
      assert_response 200
      get :show, params: {format: :json_api, motion_id: motion.id}
      assert_response 200
    end

    test 'should post not create vote for closed motion' do
      post :create, params: {format: :json_api, motion_id: closed_question_motion.id, vote: {for: :con}}
      assert_response 403
      get :show, params: {format: :json_api, motion_id: motion.id}
      assert_response 404
    end

    private

    def key(motion_id, session_id)
      "guest.votes.motions.#{motion_id}.#{session_id}"
    end
  end
end
