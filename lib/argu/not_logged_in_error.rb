module Argu
  class NotLoggedInError < StandardError
    attr_accessor :preview, :redirect

    def initialize(message = nil, preview = nil, opts = {})
      super(message)
      self.preview = preview || opts[:preview]
      self.redirect = opts[:redirect]
    end

    def r
      r!.to_s.presence
    end

    def r!
      redirect
    end
  end
end
