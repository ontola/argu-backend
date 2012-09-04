class ApplicationController < ActionController::Base
  #protect_from_forgery

  #before_filter :set_locale

  rescue_from ActiveRecord::RecordNotUnique, with: lambda {
    flash[:warning] = t(:vote_same_twice_warning)
    redirect_to :back
  }

  def set_locale
    unless current_user.nil?
      I18n.locale = current_user.settings.locale || I18n.default_locale
    end
  end
end
