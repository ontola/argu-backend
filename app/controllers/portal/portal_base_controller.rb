# frozen_string_literal: true
class Portal::PortalBaseController < ApplicationController
  before_action :authorize_staff

  private

  def authorize_staff
    return if current_user.profile.has_role?(:staff)
    raise Argu::NotAuthorizedError.new(query: "#{params[:action]}?")
  end
end
