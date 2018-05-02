# frozen_string_literal: true

module Argu
  module Authorization
    extend ActiveSupport::Concern

    included do
      include OauthHelper
    end

    module ClassMethods
      def setup_authorization
        skip_before_action :verify_authenticity_token, unless: :verify_authenticity_token?
        prepend_before_action :write_client_access_token
        before_action :doorkeeper_authorize!
        after_action :verify_authorized, except: :index, unless: :devise_controller?
        after_action :verify_policy_scoped, only: :index

        alias_attribute :pundit_user, :user_context
      end
    end

    def tree_root_id; end

    def skip_verify_policy_authorized(sure = false)
      @_pundit_policy_authorized = true if sure
    end

    def skip_verify_policy_scoped(sure = false)
      @_pundit_policy_scoped = true if sure
    end

    def verify_authenticity_token?
      doorkeeper_token.nil? || doorkeeper_guest_token? || !doorkeeper_oauth_header?
    end

    def user_context
      @user_context ||=
        UserContext.new(
          doorkeeper_scopes: doorkeeper_scopes,
          profile: current_profile,
          tree_root_id: @_error_mode ? nil : tree_root_id,
          user: current_user
        )
    end
  end
end
