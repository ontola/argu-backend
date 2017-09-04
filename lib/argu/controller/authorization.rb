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
      UserContext.new(
        current_user,
        current_profile,
        doorkeeper_scopes
      )
    end

    def policy(record, outside_tree: false)
      p = super record
      p.outside_tree = true if outside_tree
      p
    end
  end
end
