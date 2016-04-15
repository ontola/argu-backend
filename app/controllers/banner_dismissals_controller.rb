class BannerDismissalsController < AuthorizedController
  skip_before_action :check_if_registered

  def create
    dismissal = BannerDismissal.new banner_dismissal_params
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

  def check_if_member
    if authenticated_resource!.present?
      case authenticated_resource!.banner.audience.to_sym
      when :guests then !current_user
      when :users then current_user && !current_user.member_of?(authenticated_context)
      when :members then current_user && current_user.member_of?(authenticated_context)
      when :everyone then true
      end
    else
      super
    end
  end
end
