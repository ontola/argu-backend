class Portal::PortalBaseController < ApplicationController
  before_action :authorize_staff

  private

  def authorize_staff
    unless current_user && current_user.profile.has_role?(:staff)
      raise NotAuthorizedError
    end
  end
end
