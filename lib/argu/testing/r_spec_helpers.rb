module Argu
  module Testing
    module RSpecHelpers
      def sign_in(user)
        login_as(user, scope: :user)
      end
    end
  end
end
