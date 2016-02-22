module Portal
  class AnnouncementsController < PortalBaseController
    before_action :set_settings_view_path

    def new
      authorize authenticated_resource!, :new?

      render settings_location,
             locals: {
                 announcement: authenticated_resource!,
                 tab: 'announcements/new',
                 active: 'announcements'
             }
    end

    def create
      @cb = CreateAnnouncement
                .new(current_user.profile,
                     announcement_params)
      authorize @cb.resource, :create?
      @cb.on(:create_announcement_successful) do |announcement|
        respond_to do |format|
          format.html do
            redirect_to announcements_settings_path,
                        notice: t('type_create_success',
                                  type: t('announcements.type'))
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
      announcement = Announcement.find params[:id]
      authorize announcement, :edit?

      render settings_location,
             locals: {
                 announcement: announcement,
                 tab: 'announcements/edit',
                 active: 'announcements'
             }
    end

    def update
      announcement = Announcement.find params[:id]
      authorize announcement, :update?

      respond_to do |format|
        if announcement.update announcement_params
          format.html { redirect_to announcements_settings_path }
        else
          format.html do
            render settings_location,
                   locals: {
                       announcement: announcement,
                       tab: 'announcements/edit',
                       active: 'announcements'
                   }
          end
        end
      end
    end

    def destroy
      announcement = Announcement.find params[:id]
      authorize announcement, :destroy?

      respond_to do |format|
        if announcement.destroy
          format.html do
            flash[:success] = t('type_destroyed',
                                type: t('announcements.type'))
            redirect_to announcements_settings_path
          end
        else
          format.html do
            flash[:error] = t('type_destroyed_failed',
                              type: t('announcements.type'))
            redirect_to announcements_settings_path
          end
        end
      end
    end

    private

    def authenticated_resource!
      if params[:action] == 'new' || params[:action] == 'create'
        controller_name
            .classify
            .constantize
            .new
      else
        Announcement.find(params[:id])
      end
    end

    def announcement_params
      params
          .require(:announcement)
          .permit(*policy(authenticated_resource! || Announcement).permitted_attributes)
    end

    def announcements_settings_path
      settings_portal_path(tab: :announcements)
    end

    def set_settings_view_path
      prepend_view_path 'app/views/portal/portal'
    end

    def settings_location
      'portal/portal/home'
    end

    def tenant_by_param
      portal_request? ? nil : super
    end

  end
end
