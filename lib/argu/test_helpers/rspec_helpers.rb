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

      def sign_in(user)
        login_as(user, scope: :user)
      end
    end
  end
end
