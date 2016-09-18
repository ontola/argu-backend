require 'test_helper'

class OauthTest < ActionDispatch::IntegrationTest
  define_freetown

  ####################################
  # As Guest
  ####################################
  test 'guest should assign guest token' do
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      get forum_path('freetown')
    end

    assert_equal %w(guest), Doorkeeper::AccessToken.last.scopes.to_a
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should login with password grant' do
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post oauth_token_path(
        username: user.email,
        password: user.password,
        grant_type: 'password',
        scope: 'user'
      )
    end

    at = Doorkeeper::AccessToken.last
    assert_equal %w(user), at.scopes.to_a
    assert_equal user.id, at.resource_owner_id.to_i(10)
    assert cookies['client_token'].present?

    assert_redirected_to root_path
  end
end
