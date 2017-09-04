# frozen_string_literal: true

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
      Doorkeeper::Application.argu,
      user.id,
      'user',
      1.minute,
      false
    )
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

    assert_nil parsed_cookies['expires']
    at = Doorkeeper::AccessToken.last
    assert_equal %w(user), at.scopes.to_a
    assert_equal user.id, at.resource_owner_id.to_i
    assert response.cookies['argu_client_token'].present?

    assert_redirected_to root_path
  end

  test 'user should login with password grant with remember me' do
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post oauth_token_path,
           params: {
             username: user.email,
             password: user.password,
             grant_type: 'password',
             remember_me: 'true',
             scope: 'user'
           },
           headers: {
             HTTP_HOST: 'argu.co'
           }
    end

    assert_not_nil parsed_cookies['expires']
    at = Doorkeeper::AccessToken.last
    assert_equal %w(user), at.scopes.to_a
    assert_equal user.id, at.resource_owner_id.to_i
    assert response.cookies['argu_client_token'].present?

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
    assert response.cookies['argu_client_token'].present?

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

    assert parsed_body['access_token'].present?
    token = JWT.decode(parsed_body['access_token'],
                       Rails.application.secrets.jwt_encryption_token,
                       algorithm: 'HS256')[0]

    assert_equal user.email, token.dig('user', 'email')
    assert_equal user.id, token.dig('user', 'id')
    assert_equal 'user', token.dig('user', 'type')

    assert_equal 1_209_600, parsed_body['expires_in']
    assert_equal 'user', parsed_body['scope']
    assert_equal 'bearer', parsed_body['token_type']
  end

  private

  def parsed_cookies
    return @parsed_cookies if @parsed_cookies.present?
    kv_pairs = response.header['Set-Cookie'].split(/\s*;\s*/).map do |attr|
      k, v = attr.split '='
      [k, v || nil]
    end

    @parsed_cookies = Hash[kv_pairs]
  end
end
