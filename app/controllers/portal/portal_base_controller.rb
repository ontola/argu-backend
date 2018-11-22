# frozen_string_literal: true

class Portal::PortalBaseController < AuthorizedController
  before_action :authorize_staff

  private

  def authorize_staff
    return if current_user.is_staff?
    raise Argu::Errors::Forbidden.new(query: "#{params[:action]}?")
  end
end
