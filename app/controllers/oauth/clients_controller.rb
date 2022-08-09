# frozen_string_literal: true

module OAuth
  class ClientsController < LinkedRails::Auth::ClientsController
    private

    def available_scopes
      return super unless LinkedRails::Constraints::Whitelist.matches?(request)

      super + %w[staff]
    end

    def permitted_scopes
      return super unless LinkedRails::Constraints::Whitelist.matches?(request)

      super + %w[service]
    end

    def application_owner
      User.service
    end
  end
end
