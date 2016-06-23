module Argu
  class NotAMemberError < StandardError
    attr_accessor :forum, :redirect, :body

    # @param [Hash] options
    # @option options [Forum] forum The forum lacking a membership
    # @option options [String] r The url to redirect to after sign in
    # @option options [Hash] body The body to send with the json response
    # @return [String] the message
    def initialize(options = {})
      @forum = options[:forum]
      @redirect = options[:r]
      @body = options[:body]

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
