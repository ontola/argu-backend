# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tokens', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  include JWTHelper

  let(:third_party_app) { create(:application) }
  let(:index_path) { oauth_token_iri }
  let(:user) { create(:user) }

  def post_token(scope: :guest, params: {})
    post oauth_token_iri,
         params: params.merge(scope: scope),
         headers: {
           'Accept' => 'application/json'
         }
  end

  def oauth_token_iri
    "#{argu.iri}#{oauth_token_path}"
  end

  context 'without authorization' do
    it 'does not create a guest token' do
      post_token

      expect(response.status).to eq 400
    end
  end

  context 'with authorization' do
    it 'creates a user token' do
      expect do
        post_token(
          scope: :user,
          params: {
            client_id: Doorkeeper::Application.argu.uid,
            client_secret: Doorkeeper::Application.argu.secret,
            grant_type: 'password',
            password: user.password,
            username: user.email
          }
        )
      end.to change { Doorkeeper::AccessToken.count }.by(1)

      expect(response.status).to eq 200
      expect(parsed_body[:token_type]).to eq 'Bearer'
      expect(parsed_body[:scope]).to eq 'user'

      token = decode_token(parsed_body[:access_token])
      expect(token.dig('user', 'type')).to eq 'user'
    end

    it 'does not create a user token with wrong credentials' do
      expect do
        post_token(
          scope: :user,
          params: {
            client_id: Doorkeeper::Application.argu.uid,
            client_secret: Doorkeeper::Application.argu.secret,
            grant_type: 'password',
            password: 'wrong',
            username: user.email
          }
        )
      end.to change { Doorkeeper::AccessToken.count }.by(0)

      expect(response.status).to eq 400
    end
  end
end
