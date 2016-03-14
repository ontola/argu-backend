class BannersController < AuthorizedController

  def new
    render settings_location,
           locals: {
               banner: authenticated_resource!,
               tab: 'banners/new',
               active: 'banners'
           }
  end

  def create
    @cb = CreateBanner.new(current_user.profile,
                           banner_params.merge(resource_new_params))
    authorize @cb.resource, :create?
    @cb.on(:create_banner_successful) do |banner|
      respond_to do |format|
        format.html do
          redirect_to settings_forum_path(banner.forum, tab: :banners),
                      notice: t('type_create_success', type: t('banners.type')).capitalize
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
    render settings_location,
           locals: {
               banner: authenticated_resource,
               tab: 'banners/edit',
               active: 'banners'
           }
  end

  def update
    respond_to do |format|
      if authenticated_resource.update banner_params
        format.html { redirect_to banner_settings_path }
      else
        format.html do
          render settings_location,
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
    params.require(:banner).permit(*policy(authenticated_resource || Banner).permitted_attributes)
  end
end
