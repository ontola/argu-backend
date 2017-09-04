# frozen_string_literal: true

module Argu
  class InvalidCredentialsError < StandardError
    def initialize(msg = nil)
      super
    end
  end
end
