class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery #secret: "Nl4EV8Fm3LdKayxNtIBwrzMdH9BD18KcQwSczxh1EdDbtyf045rFuVces8AdPtobC9pp044KsDkilWfvXoDADZWi6Gnwk1vf3GghCIdKXEh7yYg41Tu1vWaPdyzH7solN33liZppGlJlNTlJjFKjCoGjZP3iJhscsYnPVwY15XqWqmpPqjNiluaSpCmOBpbzWLPexWwBSOvTcd6itoUdWUSQJEVL3l0rwyJ76fznlNu6DUurFb8bOL2ItPiSit7g"
  after_action :verify_authorized, :except => :index, :unless => :devise_controller?
  after_action :verify_policy_scoped, :only => :index
  before_action :set_local_scope

  rescue_from ActiveRecord::RecordNotUnique, with: lambda {
    flash[:warning] = t(:vote_same_twice_warning)
    redirect_to :back
  }

  rescue_from Pundit::NotAuthorizedError do |exception|
    respond_to do |format|
      format.js { head 403 }
      format.html {
        request.env['HTTP_REFERER'] ||= root_path
        redirect_to :back, :alert => exception.message
      }
    end
  end

  def set_locale
    unless current_user.nil?
      I18n.locale = current_user.settings.locale || I18n.default_locale
    end
  end

  def set_local_scope
    if subdomain.present?
      @_argu_scope = Organisation.find_by web_url: subdomain
      if @_argu_scope && policy(@_argu_scope).show?
        @local_title = subdomain
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end

  def subdomain
    request.subdomain.presence != 'www' ? request.subdomain : nil
  end

end
