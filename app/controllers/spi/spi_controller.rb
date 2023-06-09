# frozen_string_literal: true

module SPI
  class SPIController < ActionController::API
    include LinkedRails::Controller::Authorization
    include LinkedRails::Controller::ErrorHandling
    include Argu::Controller::ErrorHandling
    include Argu::Controller::ErrorHandling::BadCredentials
    include JsonAPIHelper
    include Argu::Controller::Authentication
    include Argu::Controller::Authorization
    include OAuthHelper

    private

    def handle_error(error)
      Rails.logger.error(error)
      error_response_json_api(error)
    end
  end
end
