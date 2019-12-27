# frozen_string_literal: true

module Argu
  module Controller
    module Authentication
      extend ActiveSupport::Concern

      included do
        include OauthHelper
      end

      def allowed_scopes
        %i[user guest service]
      end

      # @return [Profile] The {Profile} of the {User}
      def current_profile
        current_user.profile
      end

      def skip_verify_policy_authorized(sure = false)
        @_pundit_policy_authorized = true if sure
      end

      def skip_verify_policy_scoped(sure = false)
        @_pundit_policy_scoped = true if sure
      end

      def verify_authenticity_token?
        vnext_request? || doorkeeper_token.nil? || doorkeeper_guest_token? || !doorkeeper_oauth_header?
      end

      def user_context
        @user_context ||=
          UserContext.new(
            doorkeeper_scopes: doorkeeper_scopes,
            profile: current_profile,
            user: current_user,
            vnext: vnext_request?
          )
      end
    end
  end
end
