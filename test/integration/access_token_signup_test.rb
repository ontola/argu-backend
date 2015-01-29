require "test_helper"

class AccessTokenSignupTest < ActionDispatch::IntegrationTest

  test "should not view forum without an access token" do
    get forum_path(forums(:hidden).web_url)
    assert_redirected_to root_url
  end

  test "should not view forum when access tokens are disabled" do
    get forum_path(forums(:super_hidden).web_url, at: access_tokens(:token_super_hidden).access_token)
    assert_redirected_to root_url
  end

  test "should view forum with an access token" do
    get forum_path(forums(:hidden).web_url, at: access_tokens(:token_hidden).access_token)
    assert_response :success
  end

  test "should register and become a member with an access token" do
    get forum_path(forums(:hidden).web_url, at: access_tokens(:token_hidden).access_token)
    assert_response :success

    post forum_memberships_path(forums(:hidden).web_url, r: forum_path(forums(:hidden).web_url), at: access_tokens(:token_hidden).access_token)
    assert_response :success
    assert assigns(:resource)

    assert_difference 'User.count', 1 do
      post user_registration_path, {user: {
                                     username: 'newuser',
                                     email: 'newuser@example.com',
                                     password: 'useruser',
                                     password_confirmation: 'useruser',
                                     r: forums(:hidden).web_url
                                 },
                                 at: access_tokens(:token_hidden).access_token}
    end
    assert_redirected_to edit_profile_url('newuser')
    follow_redirect!


    put profile_path('newuser'), {profile: {
                                   name: 'new user',
                                   about: 'Something ab'
                               }}
    assert_redirected_to forums(:hidden).web_url
    assert assigns(:user)
    assert assigns(:profile)
    assert_equal 1, assigns(:profile).memberships.count

    follow_redirect!
    assert_response :success
  end

end
