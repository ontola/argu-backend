class Portal::AnnouncementsController < AuthenticatedController
  skip_before_action :check_if_member
  before_action :set_settings_view_path

  def new
    authorize authenticated_resource!, :new?
    @forum = tenant_by_param

    render settings_location,
           locals: {
               announcement: authenticated_resource!,
               tab: 'announcements/new',
               active: 'announcements'
           }
  end

  def create
    set_tenant
    @cb = CreateAnnouncement
              .new(current_user.profile,
                   announcement_params)
    authorize @cb.resource, :create?
    @cb.on(:create_announcement_successful) do |announcement|
      respond_to do |format|
        format.html do
          redirect_to after_create_path(announcement),
                      notice: t('banners.notices.created')
        end
      end
    end
    @cb.on(:create_announcement_failed) do |announcement|
      respond_to do |format|
        format.html { render settings_location,
                             locals: {
                                 announcement: announcement,
                                 tab: 'announcements/new',
                                 active: 'announcements'
                             } }
      end
    end
    @cb.commit
  end

  def edit
    banner = Announcement.find params[:id]
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
      if banner.update announcement_params
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
          redirect_to settings_forum_path(@forum, tab: :announcements)
        end
      else
        format.html do
          flash[:error] = t('type_destroyed_failed', type: t('banners.type'))
          redirect_to settings_forum_path(@forum, tab: :announcements)
        end
      end
    end
  end

  private

  def after_create_path(banner)
    if portal_request?
      settings_portal_path(tab: :announcements)
    else
      settings_forum_path(banner.forum, tab: :announcements)
    end
  end

  def authenticated_resource!
    if params[:action] == 'new' || params[:action] == 'create'
      controller_name
          .classify
          .constantize
          .new
    else
      super
    end
  end

  def announcement_params
    params
        .require(:announcement)
        .permit(*policy(@announcement || Announcement)
                     .permitted_attributes)
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
      settings_portal_path(tab: :announcements)
    else
      settings_forum_path(@forum, tab: :announcements)
    end
  end

  def tenant_by_param
    portal_request? ? nil : super
  end

end
