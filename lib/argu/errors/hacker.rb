# frozen_string_literal: true

module Argu
  module Errors
    class Hacker < StandardError
      attr_accessor :request

      def initialize(message = nil, _request = nil)
        super(message)
      end
    end
  end
end
