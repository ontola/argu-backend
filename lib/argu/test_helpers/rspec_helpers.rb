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

      def sign_in(user)
        login_as(user, scope: :user)
      end
    end
  end
end
