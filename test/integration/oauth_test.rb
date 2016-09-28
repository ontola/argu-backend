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

    assert_no_difference('Doorkeeper::AccessToken.count',
                         'Guest tokens should only be set when expired') do
      get forum_path('freetown')
    end
  end

  test 'guest should assign guest token when expired' do
    t = Doorkeeper::AccessToken.find_or_create_for(
      Doorkeeper::Application.find(0),
      user.id,
      'user',
      1.minute,
      false)
    t.update(created_at: 2.minutes.ago)
    get forum_path('freetown'),
        headers: {
          'Authorization': "Bearer #{t.token}"
        }

    assert_equal %w(guest), Doorkeeper::AccessToken.last.scopes.to_a
    assert_equal session.id, Doorkeeper::AccessToken.last.resource_owner_id
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should login with password grant' do
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post oauth_token_path,
           params: {
             username: user.email,
             password: user.password,
             grant_type: 'password',
             scope: 'user'
           },
           headers: {
             HTTP_HOST: 'argu.co'
           }
    end

    at = Doorkeeper::AccessToken.last
    assert_equal %w(user), at.scopes.to_a
    assert_equal user.id, at.resource_owner_id.to_i
    assert cookies['client_token'].present?

    assert_redirected_to root_path
  end

  test 'should login with r' do
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post oauth_token_path,
           params: {
             username: user.email,
             password: user.password,
             grant_type: 'password',
             user: {
               r: forum_path(freetown)
             },
             scope: 'user'
           },
           headers: {
             HTTP_HOST: 'argu.co'
           }
    end

    at = Doorkeeper::AccessToken.last
    assert_equal %w(user), at.scopes.to_a
    assert_equal user.id, at.resource_owner_id.to_i
    assert cookies['client_token'].present?

    assert_redirected_to forum_path(freetown)
  end

  test 'user should get access token when not from argu' do
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post oauth_token_path,
           params: {
             username: user.email,
             password: user.password,
             grant_type: 'password',
             scope: 'user'
           },
           headers: {
             HTTP_HOST: '127.0.0.1:42000/'
           }
    end

    res = JSON.parse(response.body)
    assert res['access_token'].present?
    token = JWT.decode(res['access_token'],
                       Rails.application.secrets.jwt_encryption_token,
                       algorithm: 'HS256')[0]

    assert_equal user.email, token.dig('user', 'email')
    assert_equal user.id, token.dig('user', 'id')
    assert_equal 'user', token.dig('user', 'type')

    assert_equal 7200, res['expires_in']
    assert_equal 'user', res['scope']
    assert_equal 'bearer', res['token_type']
  end
end
