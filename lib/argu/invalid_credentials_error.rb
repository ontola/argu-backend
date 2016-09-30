
module Argu
  class InvalidCredentialsError < StandardError
    def initialize(msg = nil)
      super
    end
  end
end
