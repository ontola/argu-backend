# frozen_string_literal: true

module Argu
  module TestHelpers
    module Fixes
      def click_button(locator = nil, options = {})
        return super unless ENV['BROWSER'] == 'firefox'
        if locator.is_a? Hash
          locator = nil
          options = locator
        end
        find(:button, locator, options).send_keys(:enter)
      end

      def click_link(locator = nil, options = {})
        return super unless ENV['BROWSER'] == 'firefox'
        if locator.is_a? Hash
          locator = nil
          options = locator
        end
        find(:link, locator, options).send_keys(:enter)
      end

      def click_on(locator = nil, options = {})
        return super unless ENV['BROWSER'] == 'firefox'
        if locator.is_a? Hash
          locator = nil
          options = locator
        end
        find(:link_or_button, locator, options).send_keys(:enter)
      end
    end
  end
end
