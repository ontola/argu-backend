# frozen_string_literal: true

# app/controllers/oauth/applications_controller.rb
class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  include OauthHelper, Argu::ErrorHandling
  respond_to :html

  def index
    @applications = Doorkeeper::Application.all
  end

  # only needed if each application must have some owner
  def create
    @application = Doorkeeper::Application.new(application_params)
    @application.owner = current_resource_owner if Doorkeeper.configuration.confirm_application_owner?
    if @application.save
      flash[:notice] = I18n.t(:notice, scope: %i[doorkeeper flash applications create])
      respond_with(:oauth, @application, location: oauth_application_url(@application))
    else
      render :new
    end
  end

  private

  def authenticate_admin!
    raise Argu::NotAuthorizedError.new(query: "#{params[:action]}?") unless current_user&.profile&.has_role?(:staff)
  end
end
