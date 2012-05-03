class ApplicationController < ActionController::Base
  require 'has_restful_permissions'
  
  protect_from_forgery
  include SessionsHelper

   def rescue_action(exception)
    case exception
      when PermissionViolation
        flash[:warning] = "You do not have permission for this action."
        redirect_to :back
      else
        super
    end
  end

end
