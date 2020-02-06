# frozen_string_literal: true

module Oauth
  class TokensController < Doorkeeper::TokensController
    def r_with_authenticity_token; end
    include RedisResourcesHelper
    include Argu::Controller::ErrorHandling::Helpers

    def create
      super

      process_previous_token(authorize_response) if status == 200
    end

    private

    def handle_token_exception(exception)
      error = get_error_response_from_exception(exception)
      headers.merge!(error.headers)
      self.response_body = error.body.merge(code: error_id(exception)).to_json
      self.status = error.status
    end

    def process_previous_token(res)
      return unless doorkeeper_token

      schedule_redis_resource_worker(
        GuestUser.new(id: doorkeeper_token.resource_owner_id),
        User.find(res.token.resource_owner_id),
        params[:r]
      )
    end
  end
end
