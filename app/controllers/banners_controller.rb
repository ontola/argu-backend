class BannersController < AuthorizedController
  def new
    render 'forums/settings',
           locals: {
             banner: authenticated_resource!,
             tab: 'banners/new',
             active: 'banners'
           }
  end

  def create
    create_service.subscribe(ActivityListener.new(creator: current_profile,
                                                  publisher: current_user))
    create_service.on(:create_banner_successful) do |banner|
      respond_to do |format|
        format.html do
          redirect_to settings_forum_path(banner.forum, tab: :banners),
                      notice: t('type_create_success', type: t('banners.type')).capitalize
        end
      end
    end
    create_service.on(:create_banner_failed) do |banner|
      respond_to do |format|
        format.html { render 'forums/settings',
                             locals: {
                                 banner: banner,
                                 tab: 'banners/new',
                                 active: 'banners'
                             } }
      end
    end
    create_service.commit
  end

  def edit
    render 'forums/settings',
           locals: {
               banner: authenticated_resource,
               tab: 'banners/edit',
               active: 'banners'
           }
  end

  def update
    respond_to do |format|
      if authenticated_resource.update permit_params
        format.html { redirect_to settings_forum_path(resource_tenant, tab: 'banners') }
      else
        format.html do
          render 'forums/settings',
                 locals: {
                     banner: authenticated_resource,
                     tab: 'banners/edit',
                     active: 'banners'
                 }
        end
      end
    end
  end

  def destroy
    respond_to do |format|
      if authenticated_resource.destroy
        format.html do
          flash[:success] = t('type_destroyed', type: t('banners.type'))
          redirect_to settings_forum_path(resource_tenant, tab: :banners)
        end
      else
        format.html do
          flash[:error] = t('type_destroyed_failed', type: t('banners.type'))
          redirect_to settings_forum_path(resource_tenant, tab: :banners)
        end
      end
    end
  end

  private

  def permit_params
    params.require(:banner).permit(*policy(resource_by_id || new_resource_from_params || Banner).permitted_attributes)
  end

  def create_service
    @create_service ||= CreateBanner.new(current_user.profile,
                                         permit_params.merge(resource_new_params))
  end
end
