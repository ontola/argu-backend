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


  end

end
