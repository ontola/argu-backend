class BannersController < AuthenticatedController
  def new
    authorize authenticated_resource!, :new?
    @forum = tenant_by_param

    render 'forums/settings',
           locals: {
               banner: authenticated_resource!,
               tab: 'banners/new',
               active: 'banners'
           }
  end

  def create
    set_tenant
    @cb = CreateBanner.new(current_user.profile,
                           banner_params.merge({
                                             forum: tenant_by_param
                                         }))
    authorize @cb.resource, :create?
    @cb.on(:create_banner_successful) do |banner|
      respond_to do |format|
        format.html { redirect_to settings_forum_path(banner.forum, tab: :banners), notice: t('banners.notices.created') }
      end
    end
    @cb.on(:create_banner_failed) do |banner|
      respond_to do |format|
        format.html { render action: 'form',
                             locals: {argument: argument} }
      end
    end
    @cb.commit
  end

  private

  def banner_params
    params.require(:banner).permit(*policy(@banner || Banner).permitted_attributes)
  end

end