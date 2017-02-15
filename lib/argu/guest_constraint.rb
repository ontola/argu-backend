# frozen_string_literal: true
module Argu
  module GuestConstraint
    module_function

    def matches?(request)
      return false unless request.headers['HTTP_ALLOW_GUEST'] == 'true'
      token = Doorkeeper.authenticate(request)
      true if !token || token&.scopes&.include?('guest')
    end
  end
end
