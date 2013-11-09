class ApplicationController < ActionController::Base
  protect_from_forgery secret: "Nl4EV8Fm3LdKayxNtIBwrzMdH9BD18KcQwSczxh1EdDbtyf045rFuVces8AdPtobC9pp044KsDkilWfvXoDADZWi6Gnwk1vf3GghCIdKXEh7yYg41Tu1vWaPdyzH7solN33liZppGlJlNTlJjFKjCoGjZP3iJhscsYnPVwY15XqWqmpPqjNiluaSpCmOBpbzWLPexWwBSOvTcd6itoUdWUSQJEVL3l0rwyJ76fznlNu6DUurFb8bOL2ItPiSit7g"

  #before_filter :set_locale

  rescue_from ActiveRecord::RecordNotUnique, with: lambda {
    flash[:warning] = t(:vote_same_twice_warning)
    redirect_to :back
  }

  rescue_from CanCan::AccessDenied do |exception|
    puts exception.to_json.to_s
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    request.env['HTTP_REFERER'] ||= root_path
    redirect_to :back, :alert => exception.message
  end

  def set_locale
    unless current_user.nil?
      I18n.locale = current_user.settings.locale || I18n.default_locale
    end
  end
end
