module Argu
  class NotAUserError < StandardError
    attr_accessor :preview, :forum, :r

    def initialize(forum, r, message = nil, preview = nil)
      super(message)
      self.preview = preview
      self.forum = forum
      self.r = r
    end
  end
end
