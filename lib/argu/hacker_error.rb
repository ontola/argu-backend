module Argu
  class HackerError < StandardError
    attr_accessor :preview

    def initialize(message = nil, request = nil)
      super(message)
      self.request = request
    end
  end
end
