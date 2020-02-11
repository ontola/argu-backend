# frozen_string_literal: true

# app/controllers/oauth/applications_controller.rb
module Oauth
  class ApplicationsController < Doorkeeper::ApplicationsController
    include LinkedRails::Controller::ErrorHandling
    include Argu::Controller::ErrorHandling
    include OauthHelper

    def index
      @applications = Doorkeeper::Application.all
    end

    # only needed if each application must have some owner
    def create
      @application = Doorkeeper::Application.new(application_params)
      @application.owner = current_resource_owner if Doorkeeper.configuration.confirm_application_owner?
      if @application.save
        respond_with(:oauth, @application, location: oauth_application_url(@application))
      else
        render :new
      end
    end

    private

    def authenticate_admin!
      raise Argu::Errors::Forbidden.new(query: "#{params[:action]}?") unless current_user&.is_staff?
    end
  end
end
