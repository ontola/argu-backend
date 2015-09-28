module Argu
  class NotAUserError < StandardError
    attr_accessor :preview, :forum, :redirect

    def initialize(forum, r, message = nil, preview = nil)
      super(message)
      self.preview = preview
      self.forum = forum
      self.redirect = r
    end

    def r
      r!.to_s.presence
    end

    def r!
      redirect
    end
  end
end
