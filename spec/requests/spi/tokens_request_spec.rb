# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Tokens', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  include JWTHelper

  let(:third_party_app) { create(:application) }
  let(:index_path) { oauth_token_path }
  let(:request_token) { nil }
  let(:user) { create(:user) }

  def post_token(auth: nil, scope: :guest, params: {})
    headers =
      if auth.present?
        {
          Authorization: "Bearer #{auth.token}"
        }
      end

    post spi_token_path,
         params: params.merge(scope: scope),
         headers: headers
  end

  context 'without authorization' do
    it 'does not create a guest token' do
      post_token

      puts response.body
      expect(response.status).to eq 401
    end
  end

  context 'with 3rd party application' do
    let!(:request_token) { create(:access_token, application_id: third_party_app.id) }

    it 'does not create a guest token' do
      post spi_token_path,
           params: {
             scopes: 'guest'
           },
           headers: {
             Authorization: "Bearer #{request_token.token}"
           }

      puts response.body
      expect(response.status).to eq 403
    end
  end

  context 'with argu front end' do
    let!(:request_token) do
      create(:access_token,
             :service,
             application_id: Doorkeeper::Application.const_get(:AFE_ID))
    end

    it 'creates a guest token' do
      expect do
        post_token auth: request_token
      end.to change { Doorkeeper::AccessToken.count }.by(1)

      expect(response.status).to eq 201
      expect(parsed_body[:token_type]).to eq 'Bearer'
      expect(parsed_body[:scope]).to eq 'guest afe'

      token = decode_token(parsed_body[:access_token])
      expect(token.dig('user', 'type')).to eq 'guest'
    end

    it 'creates a user token' do
      expect do
        post_token auth: request_token,
                   scope: :user,
                   params: {
                     password: user.password,
                     username: user.email
                   }
      end.to change { Doorkeeper::AccessToken.count }.by(1)

      expect(response.status).to eq 201
      expect(parsed_body[:token_type]).to eq 'Bearer'
      expect(parsed_body[:scope]).to eq 'user afe'

      token = decode_token(parsed_body[:access_token])
      expect(token.dig('user', 'type')).to eq 'user'
    end

    it 'does not create a user token with wrong credentials' do
      expect do
        post_token auth: request_token,
                   scope: :user,
                   params: {
                     password: 'wrong',
                     username: user.email
                   }
      end.to change { Doorkeeper::AccessToken.count }.by(0)

      expect(response.status).to eq 422
    end
  end
end
