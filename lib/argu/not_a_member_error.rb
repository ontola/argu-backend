module Argu
  class NotAMemberError < StandardError
    attr_accessor :preview, :forum, :r, :body

    def initialize(opts = {})
      super(message)
      self.preview = opts[:preview]
      self.forum = opts[:forum]
      self.r = opts[:r]
      self.body = opts[:body]
    end
  end
end
