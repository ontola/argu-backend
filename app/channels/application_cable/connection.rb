# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
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

    def doorkeeper_token
      ::Doorkeeper.authenticate(request)
    end

    def find_verified_user
      user = User.find_by(id: doorkeeper_token.try(:resource_owner_id))

      user || reject_unauthorized_connection
    end
  end
end
