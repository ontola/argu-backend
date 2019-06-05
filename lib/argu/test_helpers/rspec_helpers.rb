# frozen_string_literal: true

# Additional helpers only for RSpec
module Argu
  module TestHelpers
    module RspecHelpers
      def clear_cookies
        browser = Capybara.current_session.driver.browser
        if browser.respond_to?(:clear_cookies)
          # Rack::MockSession
          browser.clear_cookies
        elsif browser.respond_to?(:manage) && browser.manage.respond_to?(:delete_all_cookies)
          # Selenium::WebDriver
          browser.manage.delete_all_cookies
        else
          raise "Don't know how to clear cookies. Weird driver?"
        end
      end

      # Helper to aid in picking an option in a Selectize dropdown
      def fill_in_select(scope = nil, with: nil, selector: nil)
        select = lambda do
          input_field = find('.Select-control .Select-input input').native
          input_field.send_keys with
          selector ||= /#{with}/
          find('.Select-option', text: selector).click
        end
        if scope.present?
          within(scope, &select)
        else
          select.call
        end
      end

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

      def sign_in_manually(user = create(:user), navigate = true, redirect_to: freetown.iri.path)
        if navigate
          visit new_user_session_path
        else
          click_on 'Log in'
        end
        expect do
          within('#new_user') do
            fill_in 'user_email', with: user.email
            fill_in 'user_password', with: user.password
            click_button 'Log in'
          end
          expect(page).to have_current_path redirect_to
        end.to change { Doorkeeper::AccessToken.count }.by(1)
      end
      # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

      def visit(url)
        super (url.try(:iri)&.path || url).to_s.sub('app.', '')
      end
    end
  end
end
