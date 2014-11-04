class ApplicationController < ActionController::Base
  include Pundit
  #protect_from_forgery #secret: "Nl4EV8Fm3LdKayxNtIBwrzMdH9BD18KcQwSczxh1EdDbtyf045rFuVces8AdPtobC9pp044KsDkilWfvXoDADZWi6Gnwk1vf3GghCIdKXEh7yYg41Tu1vWaPdyzH7solN33liZppGlJlNTlJjFKjCoGjZP3iJhscsYnPVwY15XqWqmpPqjNiluaSpCmOBpbzWLPexWwBSOvTcd6itoUdWUSQJEVL3l0rwyJ76fznlNu6DUurFb8bOL2ItPiSit7g"
  skip_before_filter  :verify_authenticity_token
  after_action :verify_authorized, :except => :index, :unless => :devise_controller?
  after_action :verify_policy_scoped, :only => :index
  before_action :set_local_scope

  rescue_from ActiveRecord::RecordNotUnique, with: lambda {
    flash[:warning] = t(:vote_same_twice_warning)
    redirect_to :back
  }

  rescue_from Pundit::NotAuthorizedError do |exception|
    respond_to do |format|
      format.js { render 403, json: { notifications: [{type: :error, message: t("pundit.#{exception.policy.class.to_s.underscore}.#{exception.query}") }] } }
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
    if subdomain.present? && subdomain != 'logos'
      _argu_scope = Organisation.find_by web_url: subdomain
      if _argu_scope && policy(_argu_scope).show?
        @local_title = subdomain
        session[:_current_scope] = _argu_scope
        current_user._current_scope = _argu_scope if current_user.present?
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end

  def subdomain
    request.subdomain.presence != 'www' ? request.subdomain : nil
  end

end
