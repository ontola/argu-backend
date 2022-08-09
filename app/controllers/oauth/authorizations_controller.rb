# frozen_string_literal: true

module OAuth
  class AuthorizationsController < Doorkeeper::AuthorizationsController
    around_action :with_tenant_fallback
    before_action :redirect_guests

    private

    def user_context
      with_tenant_fallback do
        super
      end
    end

    def flash
      {}
    end

    def params
      super['scope'] = super['scope'].gsub('+', ' ') if super['scope'].present?

      super
    end

    def redirect_guests
      return true if (current_user && !current_user&.guest?) || response_body

      redirect_to(LinkedRails.iri(path: '/u/session/new', query: {redirect_url: request.original_url}.to_param).to_s)
    end

    def redirect_or_render(auth)
      if auth.redirectable?
        redirect_to auth.redirect_uri
      else
        render json: auth.body, status: auth.status
      end
    end
  end
end
