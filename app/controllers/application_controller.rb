class ApplicationController < ActionController::Base
  include Pundit
  helper_method :current_profile, :current_context, :current_scope
  protect_from_forgery secret: "Nl4EV8Fm3LdKayxNtIBwrzMdH9BD18KcQwSczxh1EdDbtyf045rFuVces8AdPtobC9pp044KsDkilWfvXoDADZWi6Gnwk1vf3GghCIdKXEh7yYg41Tu1vWaPdyzH7solN33liZppGlJlNTlJjFKjCoGjZP3iJhscsYnPVwY15XqWqmpPqjNiluaSpCmOBpbzWLPexWwBSOvTcd6itoUdWUSQJEVL3l0rwyJ76fznlNu6DUurFb8bOL2ItPiSit7g"
  skip_before_filter  :verify_authenticity_token
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :verify_authorized, :except => :index, :unless => :devise_controller?
  after_action :verify_policy_scoped, :only => :index

  rescue_from ActiveRecord::RecordNotUnique, with: lambda {
    flash[:warning] = t(:vote_same_twice_warning)
    redirect_to :back
  }

  rescue_from Pundit::NotAuthorizedError do |exception|
    respond_to do |format|
      format.js { render 403, json: { notifications: [{type: :error, message: t("pundit.#{exception.policy.class.to_s.underscore}.#{exception.query}") }] } }
      format.html {
        request.env['HTTP_REFERER'] = request.env['HTTP_REFERER'] == request.original_url || request.env['HTTP_REFERER'].blank? ? root_path : request.env['HTTP_REFERER']
        redirect_to :back, :alert => exception.message
      }
    end
  end

  def current_scope
    current_context.context_scope || current_context
  end

  # Returns the current context, if a param is given, it will serve as the start of the current context
  def current_context(model=nil)
    @current_context ||= Context.parse_from_uri(request.url, model)
  end

  # @return #Profile
  def current_profile
    if current_user.present?
      current_user.profile
    else
      nil
    end
  end

  def set_locale
    unless current_user.nil?
      I18n.locale = current_user.settings.locale || I18n.default_locale
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username
    devise_parameter_sanitizer.for(:accept_invitation).concat [:username]
  end

end
