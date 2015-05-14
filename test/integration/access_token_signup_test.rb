require 'test_helper'

class AccessTokenSignupTest < ActionDispatch::IntegrationTest

  test 'should redirect to root when accessing a forum without an access token' do
    get forum_path(forums(:hidden))
    assert_not assigns(:items), 'render not interrupted with an NotLoggedInException'
    assert_response 404, 'Existence of hidden forums is leaked'
  end

  test 'should not view forum when access tokens are disabled' do
    get forum_path(forums(:super_hidden), at: access_tokens(:token_super_hidden).access_token)
    assert_response 404
  end

  test 'should view forum with an access token' do
    get forum_path(forums(:hidden), at: access_tokens(:token_hidden).access_token)
    assert_response :success
  end

  test 'should update counters accordingly' do
    assert_differences [['access_tokens(:token_hidden).reload.sign_ups', 0],
                        ['access_tokens(:token_hidden).reload.usages', 1]] do
      get forum_path(forums(:hidden), at: access_tokens(:token_hidden).access_token)
    end
    assert_response :success

    assert_differences [['access_tokens(:token_hidden).reload.sign_ups', 0],
                        ['access_tokens(:token_hidden).reload.usages', 0]],
                        'Usages or sign_ups counter changed on secondary get w/ token' do
      get forum_path(forums(:hidden), at: access_tokens(:token_hidden).access_token)
      assert_response :success
    end

    assert_differences [['access_tokens(:token_hidden).reload.sign_ups', 0],
                        ['access_tokens(:token_hidden).reload.usages', 0]] do
      post forum_memberships_path(forums(:hidden), r: forum_path(forums(:hidden)), at: access_tokens(:token_hidden).access_token)
    end
    assert_response :success
    assert assigns(:resource)

    assert_differences [['User.count', 1],
                        ['access_tokens(:token_hidden).reload.sign_ups', 1],
                        ['access_tokens(:token_hidden).reload.usages', 0]] do
      post user_registration_path, {user: {
                                     shortname_attributes: {shortname: 'newuser'},
                                     email: 'newuser@example.com',
                                     password: 'useruser',
                                     password_confirmation: 'useruser',
                                     r: forums(:hidden).url
                                 },
                                    at: access_tokens(:token_hidden).access_token}
    end

  end

  # Note: The :at params are duplicated everywhere because integration tests apparently don't support session variables
  test 'should register and become a member with an access token' do
    get forum_path(forums(:hidden).url, at: access_tokens(:token_hidden).access_token)
    assert_response :success

    post forum_memberships_path(forums(:hidden).url, r: forum_path(forums(:hidden).url), at: access_tokens(:token_hidden).access_token)
    assert_response :success
    assert assigns(:resource)

    assert_difference 'User.count', 1 do
      post user_registration_path, {user: {
                                     shortname_attributes: {shortname: 'newuser'},
                                     email: 'newuser@example.com',
                                     password: 'useruser',
                                     password_confirmation: 'useruser',
                                     r: forums(:hidden).url
                                 },
                                 at: access_tokens(:token_hidden).access_token}
    end
    assert_redirected_to edit_user_url('newuser')
    follow_redirect!


    put profile_path('newuser'), {profile: {
                                   profileable_attributes: {
                                       first_name: 'new',
                                       last_name: 'user'
                                   },
                                   about: 'Something ab'
                               }}
    assert_redirected_to forums(:hidden).url
    assert assigns(:resource)
    assert assigns(:profile)
    assert_equal 1, assigns(:profile).memberships.count

  end

  test 'should register and become a member with an access token and preserve vote' do
    get forum_path(forums(:hidden).url, at: access_tokens(:token_hidden).access_token)
    assert_response :success

    post motion_vote_path(motions(:hidden_one), 'neutral')
    assert_response :success

    post forum_memberships_path(forums(:hidden).url, r: motion_vote_path(motions(:hidden_one), 'neutral'), at: access_tokens(:token_hidden).access_token)
    assert_response :success
    assert assigns(:resource)

    assert_difference 'User.count', 1 do
      post user_registration_path, {user: {
                                     shortname_attributes: {shortname: 'newuser'},
                                     email: 'newuser@example.com',
                                     password: 'useruser',
                                     password_confirmation: 'useruser',
                                     r: motion_vote_path(motions(:hidden_one), 'neutral')
                                 },
                                    at: access_tokens(:token_hidden).access_token}
    end
    assert_redirected_to edit_user_url('newuser')
    follow_redirect!


    put profile_path('newuser'), {profile: {
                                   profileable_attributes: {
                                     first_name: 'new',
                                     last_name: 'user'
                                   },
                                   about: 'Something ab'
                               }}
    assert_redirected_to motion_vote_path(motions(:hidden_one), 'neutral')
    assert_response 307
    assert assigns(:resource)
    assert assigns(:profile)
    assert_equal 'new user', assigns(:profile).display_name
    assert_equal 1, assigns(:profile).memberships.count

    assert_difference 'Vote.count', 1 do
      post response.location
      assert_response 302
    end

    follow_redirect!
    assert_response :success
  end

end
