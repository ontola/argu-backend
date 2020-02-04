# frozen_string_literal: true

# Additional helpers only for RSpec
module Argu
  module TestHelpers
    module RspecHelpers
      # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      def sign_in(user, app = Doorkeeper::Application.argu)
        scopes = user == :guest ? 'guest' : 'user'
        scopes += ' afe' if app.id == Doorkeeper::Application::AFE_ID
        user_id = user == :guest ? (@request&.session&.id || SecureRandom.hex) : user.id
        t = Doorkeeper::AccessToken.new(
          application: app,
          resource_owner_id: user_id,
          scopes: scopes,
          expires_in: 10.minutes
        )
        if scopes.include?('guest')
          t.send(:generate_token)
        else
          t.save!
        end
        if defined?(cookies) && defined?(cookies.encrypted)
          set_argu_client_token_cookie(t.token)
        else
          allow(Doorkeeper::OAuth::Token)
            .to receive(:cookie_token_extractor).and_return(t.token)
        end
      end
    end
  end
end
