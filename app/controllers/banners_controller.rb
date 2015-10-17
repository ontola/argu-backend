class BannersController < AuthorizedController
  skip_before_action :check_if_member, if: :portal_request?
  before_action :set_settings_view_path

  def new
    authorize authenticated_resource!, :new?
    @forum = tenant_by_param

    render settings_location,
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
        format.html do
          redirect_to settings_forum_path(banner.forum, tab: :banners),
                      notice: t('banners.notices.created')
        end
      end
    end
    @cb.on(:create_banner_failed) do |banner|
      respond_to do |format|
        format.html { render settings_location,
                             locals: {
                                 banner: banner,
                                 tab: 'banners/new',
                                 active: 'banners'
                             } }
      end
    end
    @cb.commit
  end

  def edit
    banner = Banner.find params[:id]
    set_tenant
    authorize banner, :edit?

    render settings_location,
           locals: {
               banner: banner,
               tab: 'banners/edit',
               active: 'banners'
           }
  end

  def update
    banner = Banner.find params[:id]
    set_tenant
    authorize banner, :update?

    respond_to do |format|
      if banner.update banner_params
        format.html { redirect_to banner_settings_path }
      else
        format.html do
          render settings_location,
                 locals: {
                     banner: banner,
                     tab: 'banners/edit',
                     active: 'banners'
                 }
        end
      end
    end
  end

  def destroy
    banner = Banner.find params[:id]
    set_tenant
    authorize banner, :destroy?

    respond_to do |format|
      if banner.destroy
        format.html do
          flash[:success] = t('type_destroyed', type: t('banners.type'))
          redirect_to settings_forum_path(@forum, tab: :banners)
        end
      else
        format.html do
          flash[:error] = t('type_destroyed_failed', type: t('banners.type'))
          redirect_to settings_forum_path(@forum, tab: :banners)
        end
      end
    end
  end

  private

  def authenticated_resource!
    if params[:forum_id].present?
      super
    else
      if params[:action] == 'new' || params[:action] == 'create'
        controller_name
            .classify
            .constantize
            .new forum: nil
      else
        super
      end
    end
  end

  def banner_params
    params.require(:banner).permit(*policy(@banner || Banner).permitted_attributes)
  end
end
