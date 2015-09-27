module Argu
  class NotAMemberError < StandardError
    attr_accessor :preview, :forum, :redirect, :body

    def initialize(opts = {})
      super(message)
      self.preview = opts[:preview]
      self.forum = opts[:forum]
      self.redirect = opts[:r]
      self.body = opts[:body]
    end

    def r
      r!.to_s.presence
    end

    def r!
      redirect
    end
  end
end
