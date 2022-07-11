# frozen_string_literal: true

module Argu
  module Controller
    module Authentication
      extend ActiveSupport::Concern

      included do
        include LinkedRails::Auth::Controller
        include OAuthHelper
      end

      def skip_verify_policy_authorized(sure: false)
        @_pundit_policy_authorized = true if sure
      end

      def skip_verify_policy_scoped(sure: false)
        @_pundit_policy_scoped = true if sure
      end
    end
  end
end
