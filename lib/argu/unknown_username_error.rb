# frozen_string_literal: true

module Argu
  class UnknownUsernameError < StandardError
    attr_accessor :redirect

    # @param [Hash] options
    # @option options [String] r The url to redirect to after sign in
    # @return [String] the message
    def initialize(options = {})
      @redirect = options[:r]

      message = I18n.t('devise.failure.invalid_username')
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
