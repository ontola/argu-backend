# frozen_string_literal: true

module RefreshTokenStrategyExt
  def refresh_token
    token = Doorkeeper.config.access_token_model.by_refresh_token(parameters[:refresh_token])
    token.resource_owner = UserContext.new(allow_expired: true, doorkeeper_token: token) if token
    token
  end
end
Doorkeeper::Request::RefreshToken.prepend(RefreshTokenStrategyExt)

module AccessTokenIncl
  extend ActiveSupport::Concern

  included do
    attr_reader :resource_owner

    validate :validate_scope_for_resource_owner
  end
end
Doorkeeper::AccessToken.include(AccessTokenIncl)

module AccessTokenExt
  extend ActiveSupport::Concern
  extend JWTHelper

  def resource_owner=(user_context)
    unless user_context.blank? || user_context.is_a?(UserContext)
      raise("Expected resource_owner to by a UserContext, but is a #{user_context.class}")
    end

    self.resource_owner_id = user_context&.user&.id
    @resource_owner = user_context
  end

  private

  def validate_scope_for_resource_owner
    return if resource_owner_id || scopes.to_s == 'guest'

    raise Doorkeeper::Errors::DoorkeeperError.new(:invalid_grant)
  end

  class_methods do
    def by_resource_owner(resource_owner)
      where(resource_owner_id: resource_owner_id_for(resource_owner))
    end

    def find_or_create_for(**attrs)
      return super unless attrs[:resource_owner]&.user&.is_staff? && attrs[:scopes].present?

      attrs[:scopes] =
        if attrs[:scopes].is_a?(Array)
          Doorkeeper::OAuth::Scopes.from_array(attrs[:scopes])
        else
          Doorkeeper::OAuth::Scopes.from_string(attrs[:scopes].to_s)
        end

      attrs[:scopes].add(:staff)

      super
    end

    def resource_owner_id_for(resource_owner)
      if resource_owner.is_a?(UserContext)
        resource_owner.user.id
      else
        resource_owner
      end
    end
  end
end
Doorkeeper::AccessToken.prepend(AccessTokenExt)

module ApplicationExt
  extend ActiveSupport::Concern

  ARGU_ID = 0
  AFE_ID = 1
  SERVICE_ID = 2

  class_methods do
    def argu
      Doorkeeper::Application.find(Doorkeeper::Application::ARGU_ID)
    end

    def argu_front_end
      Doorkeeper::Application.find(Doorkeeper::Application::AFE_ID)
    end

    def argu_service
      Doorkeeper::Application.find(Doorkeeper::Application::SERVICE_ID)
    end
  end
end
Doorkeeper::Application.prepend(ApplicationExt)

module PasswordAccessTokenRequestExt
  private

  def validate_client
    client.present?
  end
end
Doorkeeper::OAuth::PasswordAccessTokenRequest.prepend(PasswordAccessTokenRequestExt)