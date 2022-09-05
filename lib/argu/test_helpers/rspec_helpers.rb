# frozen_string_literal: true

# Additional helpers only for RSpec
module Argu
  module TestHelpers
    module RspecHelpers
      def sign_in(resource = create(:user))
        @bearer_token = ActsAsTenant.with_tenant(ActsAsTenant.current_tenant || argu) do
          doorkeeper_token_for(resource).token
        end
      end
    end
  end
end
