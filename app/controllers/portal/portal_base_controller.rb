class Portal::PortalBaseController < ApplicationController
  before_action :authorize_staff

  private

  def authorize_staff
    raise Argu::NotAuthorizedError unless current_user && current_user.profile.has_role?(:staff)
  end
end
