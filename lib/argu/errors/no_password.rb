# frozen_string_literal: true

module Argu
  module Errors
    class NoPassword < Doorkeeper::Errors::InvalidGrantReuse
      attr_accessor :redirect

      # @param [Hash] options
      # @option options [String] r The url to redirect to after sign in
      # @return [String] the message
      def initialize(**options)
        if options[:user].reset_password_sent_at.blank? || options[:user].reset_password_sent_at < 1.minute.ago
          options[:user].send_reset_password_token_email
        end

        @redirect = options[:r]

        message = I18n.t('devise.failure.no_password')
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
