class ApplicationController < ActionController::Base
  protect_from_forgery

  require 'has_restful_permissions'
  include SessionsHelper

  rescue_from PermissionViolation, with: lambda {
    flash[:warning] = t(:application_system_not_allowed)
    redirect_to :back
  }

end
