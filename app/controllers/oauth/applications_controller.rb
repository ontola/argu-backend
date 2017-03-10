# frozen_string_literal: true
# app/controllers/oauth/applications_controller.rb
class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  def index
    @applications = current_resource_owner.oauth_applications
  end

  # only needed if each application must have some owner
  def create
    @application = Doorkeeper::Application.new(application_params)
    @application.owner = current_resource_owner if Doorkeeper.configuration.confirm_application_owner?
    if @application.save
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :create])
      respond_with(:oauth, @application, location: oauth_application_url(@application))
    else
      render :new
    end
  end

  private

  def authenticate_admin!
    current_user.profile.has_role?(:staff)
  end

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
