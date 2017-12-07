# frozen_string_literal: true

require 'test_helper'

module Portal
  class UsersControllerTest < ActionController::TestCase
    define_freetown
    let!(:user) { create(:motion, parent: freetown.edge).publisher }

    ####################################
    # As Guest
    ####################################
    test 'guest should not get delete' do
      get :delete, params: {id: user.url}
      assert_not_authorized
    end

    test 'guest should not delete destroy' do
      delete :destroy, params: {id: user.url}
      assert_not_authorized
    end

    ####################################
    # As User
    ####################################
    test 'user should not get delete' do
      sign_in create(:user)

      get :delete, params: {id: user.url}
      assert_not_authorized
    end

    test 'user should not delete destroy' do
      sign_in create(:user)

      delete :destroy, params: {id: user.url}
      assert_not_authorized
    end

    ####################################
    # As Staff
    ####################################
    let(:staff) { create(:user, :staff) }

    test 'staff should get delete' do
      sign_in staff
      get :delete, params: {id: user.url}
      assert_response :success
    end

    test 'staff should delete destroy user anonimising content' do
      sign_in staff

      differences = [
        ['User.count', -1],
        ['Motion.count', 0],
        ["Motion.where(publisher_id: #{User::COMMUNITY_ID}).count", 1],
        ['VoteEvent.count', 0],
        ["VoteEvent.where(publisher_id: #{User::COMMUNITY_ID}).count", 1],
        ['Edge.count', 0],
        ["Edge.where(user_id: #{User::COMMUNITY_ID}).count", 2]
      ]
      assert_differences(differences) do
        delete :destroy, params: {id: user.url, user: {confirmation_string: 'remove'}}
        assert_response 303
      end
    end

    test 'staff should delete destroy user destroying content' do
      sign_in staff

      differences = [
        ['User.count', -1],
        ['Motion.count', -1],
        ["Motion.where(publisher_id: #{User::COMMUNITY_ID}).count", 0],
        ['VoteEvent.count', -1],
        ["VoteEvent.where(publisher_id: #{User::COMMUNITY_ID}).count", 0],
        ['Edge.count', -2],
        ["Edge.where(user_id: #{User::COMMUNITY_ID}).count", 0]
      ]
      assert_differences(differences) do
        delete :destroy, params: {id: user.url, user: {confirmation_string: 'remove', destroy_content: 'true'}}
        assert_response 303
      end
    end
  end
end
