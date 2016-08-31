module Argu
  class NotAUserError < StandardError
    attr_accessor :forum, :redirect, :body

    # @param [Hash] options
    # @option options [Forum] forum The forum for the request
    # @option options [String] r The url to redirect to after sign in
    # @return [String] the message
    def initialize(options = {})
      @forum = options[:forum]
      @redirect = options[:r]
      @body = options[:body]

      message = I18n.t('devise.failure.unauthenticated')
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
