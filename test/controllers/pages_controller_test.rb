require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'should not get show without platform access' do
    get :show, id: pages(:utrecht)

    assert_response :success
    assert assigns(:_not_logged_in_caught)
    assert_nil assigns(:collection)
  end

  test 'should get show with platform access' do
    get :show, id: pages(:utrecht), at: access_tokens(:token_hidden).access_token

    assert_response :success
    assert_not_nil assigns(:profile)
    assert_not_nil assigns(:collection)

    assert assigns(:collection).values.all? { |arr| arr[:collection].all? { |v| v.forum.open? } }, 'Votes of closed fora are visible to non-members'
  end

  test 'should get show' do
    sign_in users(:user)

    get :show, id: pages(:utrecht)

    assert_response :success
    assert_not_nil assigns(:profile)
    assert_not_nil assigns(:collection)

    _memberships = assigns(:current_profile).memberships.pluck(:forum_id)
    assert assigns(:collection).values.all? { |arr| arr[:collection].all? { |v| _memberships.include?(v.forum_id) || v.forum.open? } }, 'Votes of closed fora are visible to non-members'
  end

  test 'should not show all votes' do
    sign_in users(:user2)

    get :show, id: pages(:utrecht)
    assert_response 200
    assert assigns(:collection)

    assert_not assigns(:collection)[:con][:collection].any?, 'all votes are shown'
    assert_equal pages(:utrecht).profile.votes_questions_motions.length, assigns(:collection).values.map {|i| i[:collection].length }.inject(&:+), 'Not all/too many votes are shown'
  end


end
