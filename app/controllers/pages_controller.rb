# frozen_string_literal: true
class PagesController < AuthorizedController
  skip_before_action :authorize_action, only: :settings

  def index
    @user = User.find_via_shortname params[:id]
    authorize @user, :update?
    @pages = policy_scope(Page)
               .where(id: @user.profile.granted_record_ids('Page')
                            .concat(@user.profile.pages.pluck(:id)))
               .distinct

    render locals: {
      current: current_user.profile.pages.length,
      max: policy(current_user).max_allowed_pages
    }
  end

  def show
    @forums = policy_scope(authenticated_resource.forums).joins(:edge).order('edges.follows_count DESC')
    @profile = @page.profile
    authorize @page, :show?

    respond_to do |format|
      format.html do
        if (/[a-zA-Z]/i =~ params[:id]).nil?
          redirect_to url_for(@page), status: 307
        else
          render 'show'
        end
      end
      format.json_api do
        render json: @page,
               include: [
                 :profile_photo,
                 vote_match_collection: INC_NESTED_COLLECTION
               ]
      end
    end
  end

  def new
    authenticated_resource.build_shortname
    authenticated_resource.build_profile

    render locals: {
      page: authenticated_resource,
      errors: {}
    }
  end

  def create
    @page.assign_attributes(permit_params)

    if @page.save
      redirect_to page_url(@page), status: 303
    else
      respond_to do |format|
        format.html do
          render 'new', locals: {
            page: @page,
            errors: @page.errors
          }, notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}]
        end
      end
    end
  end

  def settings
    authorize authenticated_resource, :update?

    render locals: {
      tab: tab,
      active: tab,
      resource: @page
    }
  end

  def update
    if @page.update permit_params
      redirect_to settings_page_path(@page, tab: tab)
    else
      render 'settings',
             locals: {
               tab: tab,
               active: tab
             }
    end
  end

  def delete
    respond_to do |format|
      format.html { render 'delete', locals: {resource: @page} }
      format.js { render layout: false }
    end
  end

  def destroy
    unless params[:page][:confirmation_string] == t('pages.settings.advanced.delete.confirm.string')
      @page.errors.add(:confirmation_string, t('errors.messages.should_match'))
    end
    if @page.errors.empty? && @page.destroy
      redirect_to root_path, notice: t('type_destroy_success', type: t('pages.type'))
    else
      flash[:error] = t('errors.general')
      redirect_to(delete_page_path)
    end
  end

  protected

  def authenticated_resource!
    @resource ||=
      case action_name
      when 'create', 'new'
        new_resource_from_params
      when 'trash', 'untrash'
        nil
      else
        resource_by_id
      end
  end

  def resource_by_id
    @page ||= Page.find_via_shortname params[:id]
  end

  private

  def check_if_registered
    return unless current_user.guest?
    raise Argu::NotAUserError.new(r: new_page_path)
  end

  def handle_not_authorized_error(exception)
    us_po = policy(current_user) unless current_user.guest?
    if us_po&.max_pages_reached?
      errors = {}
      errors[:max_allowed_pages] = {
        max: us_po.max_allowed_pages,
        current: current_user.profile.pages.length,
        pages_url: pages_user_url(current_user)
      }
      render 'new', locals: {
        page: new_resource_from_params,
        errors: errors
      }
    else
      super
    end
  end

  def new_resource_from_params
    @page ||= Edge.new(
      owner: Profile.new(profileable: Page.new).profileable,
      user: current_user,
      is_published: true
    ).owner
  end

  def permit_params
    return @_permit_params if defined?(@_permit_params) && @_permit_params.present?
    @_permit_params = params
                      .require(:page)
                      .permit(*policy(@page).permitted_attributes)
                      .to_h
                      .merge(owner: current_user.profile)
    merge_photo_params(@_permit_params, Page)
    @_permit_params[:last_accepted] = DateTime.current if permit_params[:last_accepted] == '1'
    @_permit_params
  end

  def tab
    @tab ||= policy(@page || Page).verify_tab(params[:tab])
  end
end
