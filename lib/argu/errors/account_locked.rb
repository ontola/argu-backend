# frozen_string_literal: true

module Argu
  module Errors
    class AccountLocked < Doorkeeper::Errors::InvalidGrantReuse
      attr_accessor :redirect

      # @param [Hash] options
      # @option options [String] r The url to redirect to after sign in
      # @return [String] the message
      def initialize(options = {})
        @redirect = options[:r]

        message = I18n.t('devise.failure.locked')
        super(message)
      end

      def r
        r!.to_s.presence
      end

      def r!
        @redirect
      end
    end
  end
end
