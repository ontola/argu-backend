class ApplicationController < ActionController::Base
  #protect_from_forgery

  require 'has_restful_permissions'
  include SessionsHelper
  before_filter :set_locale

  rescue_from PermissionViolation, with: lambda {
    flash[:warning] = t(:application_system_not_allowed)
    redirect_to :back
  }

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
