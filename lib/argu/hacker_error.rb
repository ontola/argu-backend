module Argu
  class HackerError < StandardError
    attr_accessor :request

    def initialize(message = nil, request = nil)
      super(message)
    end
  end
end
