# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    include JWTHelper

    identified_by :current_user
    identified_by :current_tenant

    def initialize(*_args)
      self.current_tenant = ActsAsTenant.current_tenant
      super
    end

    def connect
      self.current_user = find_verified_user
    end

    private

    def current_resource_owner
      instance_eval(&Doorkeeper.configuration.authenticate_resource_owner)
    end

    def doorkeeper_token
      ::Doorkeeper.authenticate(request)
    end

    def doorkeeper_token_payload
      @doorkeeper_token_payload ||= decode_token(doorkeeper_token.token)
    end

    def find_verified_user
      current_resource_owner || reject_unauthorized_connection
    end
  end
end
