# frozen_string_literal: true
class BannerDismissalsController < AuthorizedController
  skip_before_action :check_if_registered

  def create
    authenticated_resource.user = current_user
    respond_to do |format|
      if authenticated_resource.save
        # Cookie permeation cannot be done from a model
        stubborn_hmset(*authenticated_resource.stubborn_params)
        format.json { head 204 }
      else
        format.json { head 500 }
      end
    end
  end

  private

  def banner_dismissal_params
    params.require(:banner_dismissal).permit :banner_id
  end

  def authenticated_resource!
    if params[:action] == 'new' || params[:action] == 'create'
      @resource ||= BannerDismissal.new banner_dismissal_params
    else
      super
    end
  end
end
