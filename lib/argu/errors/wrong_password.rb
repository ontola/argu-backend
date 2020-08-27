# frozen_string_literal: true

module Argu
  module Errors
    class WrongPassword < Doorkeeper::Errors::InvalidGrantReuse
      attr_accessor :redirect

      # @param [Hash] options
      # @option options [String] redirect_url The url to redirect to after sign in
      # @return [String] the message
      def initialize(options = {})
        @redirect = options[:redirect_url]

        message = I18n.t('devise.failure.invalid_password')
        super(message)
      end

      def redirect_url
        redirect_url!.to_s.presence
      end

      def redirect_url!
        @redirect
      end
    end
  end
end
