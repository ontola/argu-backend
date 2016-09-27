# frozen_string_literal: true
class BannerDismissalsController < AuthorizedController
  skip_before_action :check_if_registered

  def create
    dismissal = BannerDismissal.new banner_dismissal_params
                .to_h
                .merge!(user: current_user)
    authorize dismissal, :create?
    respond_to do |format|
      if dismissal.save
        # Cookie permeation cannot be done from a model
        stubborn_hmset(*dismissal.stubborn_params)
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

  def authenticated_context
    authenticated_resource!.banner.forum
  end

  def authenticated_resource!
    if params[:action] == 'new' || params[:action] == 'create'
      BannerDismissal.new banner_dismissal_params
    else
      super
    end
  end
end
