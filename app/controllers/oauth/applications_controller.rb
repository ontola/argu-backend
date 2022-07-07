# frozen_string_literal: true

module Oauth
  class ApplicationsController < Doorkeeper::ApplicationsController
    include LinkedRails::Controller::ErrorHandling
    include Argu::Controller::ErrorHandling
    include Argu::Controller::Authentication

    private

    def authenticate_admin!
      raise Argu::Errors::Forbidden.new(query: "#{params[:action]}?") unless current_user&.is_staff?
    end
  end
end
