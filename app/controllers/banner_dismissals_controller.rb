# frozen_string_literal: true
class BannerDismissalsController < AuthorizedController
  skip_before_action :check_if_registered

  private

  def authenticated_resource!
    if params[:action] == 'new' || params[:action] == 'create'
      @resource ||= BannerDismissal.new banner_dismissal_params
    else
      super
    end
  end

  def banner_dismissal_params
    params
      .require(:banner_dismissal)
      .permit(:banner_id)
      .merge(user: current_user)
  end

  def create_handler_success(_)
    respond_to do |format|
      stubborn_hmset(*authenticated_resource.stubborn_params)
      format.json { head 204 }
    end
  end
end
