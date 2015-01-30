module Argu
  class NotLoggedInError < StandardError
    attr_accessor :preview

    def initialize(message = nil, preview = nil)
      super(message)
      self.preview = preview
    end
  end
end