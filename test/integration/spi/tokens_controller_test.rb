# frozen_string_literal: true

require 'test_helper'

module SPI
  class TokensControllerTest < ActionDispatch::IntegrationTest
    define_page
    let(:guest_user) { create_guest_user }

    ####################################
    # As Guest
    ####################################
    test 'guest should not post create' do
      sign_in guest_user

      post spi_token_path
      assert_response 403
    end

    ####################################
    # As User
    ####################################
    test 'user should not post create' do
      sign_in
      post spi_token_path
      assert_response 403
    end

    ####################################
    # As Service
    ####################################
    let(:user) { create(:user) }

    test 'service should post create guest token' do
      sign_in :service

      assert_difference('Doorkeeper::AccessToken.count', 1) do
        post spi_token_path,
             params: {
               scope: :guest
             }
      end

      assert_response 201

      body = JSON.parse(response.body)
      assert_equal 'guest', body['scope']
      assert_equal 'Bearer', body['token_type']
      assert_not_nil body['access_token']

      token = JWT.decode(parsed_body['access_token'], nil, false)[0]
      assert_not_nil token['user']
      assert_equal 'guest', token['user']['type']
      id_base = "http://#{Rails.application.config.host_name}/sessions/"
      assert token['user']['@id'].starts_with?(id_base)
      assert_equal SecureRandom.hex.length, token['user']['@id'].split(id_base).last.length

      assert_nil token['user']['email']
    end

    test 'service should post create user token' do
      sign_in :service

      assert_difference('Doorkeeper::AccessToken.count', 1) do
        post spi_token_path,
             params: {
               password: user.password,
               scope: :user,
               username: user.email
             }
      end

      assert_response 201
      validate_user_token user
    end

    test 'service should post create user token with shortname' do
      sign_in :service

      assert_difference('Doorkeeper::AccessToken.count', 1) do
        post spi_token_path,
             params: {
               password: user.password,
               scope: :user,
               username: user.shortname.shortname
             }
      end

      assert_response 201
      validate_user_token user
    end

    [
      ['without', nil],
      ['with empty', ''],
      ['with wrong', 'wrong']
    ].each do |type, value|
      test "service should not post create user token #{type} password" do
        sign_in :service

        assert_no_difference('Doorkeeper::AccessToken.count') do
          post spi_token_path,
               params: {
                 password: value,
                 scope: :user,
                 username: user.shortname.shortname
               }
        end

        validate_error Argu::Errors::WrongPassword
      end
    end

    [
      ['without', nil, Argu::Errors::UnknownUsername],
      ['with empty', '', Argu::Errors::UnknownUsername],
      ['with invalid', 'invalid_email@', Argu::Errors::UnknownEmail],
      ['with wrong', 'wrong_email@example.com', Argu::Errors::UnknownEmail]
    ].each do |type, value, error|
      test "service should not post create user token #{type} email" do
        sign_in :service

        assert_no_difference('Doorkeeper::AccessToken.count') do
          post spi_token_path,
               params: {
                 password: user.password,
                 scope: :user,
                 email: value
               }
        end

        validate_error error
      end
    end

    private

    def validate_error(error)
      assert_response Argu::Errors::TYPES[error.to_s][:status]
      assert_equal Argu::Errors::TYPES[error.to_s][:id], parsed_body['code']
    end

    def validate_user_token(user) # rubocop:disable Metrics/AbcSize
      b = parsed_body
      assert_equal 'user', b['scope']
      assert_equal 'Bearer', b['token_type']
      assert_not_nil b['access_token']

      token = JWT.decode(b['access_token'], nil, false)[0]
      assert_not_nil token['user']
      assert_equal 'user', token['user']['type']
      assert_equal user.id, token['user']['id']
      assert_equal user.iri, token['user']['@id']
      assert_equal user.email, token['user']['email']
    end
  end
end
