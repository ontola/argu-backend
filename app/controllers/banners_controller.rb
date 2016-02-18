class BannersController < AuthorizedController
  skip_before_action :check_if_member, if: :portal_request?
  before_action :set_settings_view_path

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

  def portal_request?
    params[:forum_id].blank? && policy(:Portal).home?
  end

  def set_settings_view_path
    if portal_request?
      prepend_view_path 'app/views/portal/portal'
    else
      prepend_view_path 'app/views/forums'
    end
  end

  def settings_location
    portal_request? ? 'portal/portal/home' : 'forums/settings'
  end

  def banner_settings_path
    if portal_request?
      settings_portal_path(tab: :banners)
    else
      settings_forum_path(authenticated_context, tab: :banners)
    end
  end

  def tenant_by_param
    portal_request? ? nil : super
  end

end
