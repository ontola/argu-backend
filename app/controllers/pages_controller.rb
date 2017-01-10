# frozen_string_literal: true
class PagesController < ApplicationController
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
    @page = Page.find_via_shortname!(params[:id])
    @profile = @page.profile
    authorize @page, :show?

    if @profile.are_votes_public?
      @collection = Vote.ordered(@profile.visible_votes_for(current_user))
    end

    respond_to do |format|
      format.html do
        if (/[a-zA-Z]/i =~ params[:id]).nil?
          redirect_to url_for(@page), status: 307
        else
          render 'profiles/show'
        end
      end
      format.json_api { render json: @page, include: :profile_photo }
    end
  end

  def new
    authorize new_resource_from_params, :create?

    new_resource_from_params.build_shortname
    new_resource_from_params.build_profile

    render locals: {
      page: new_resource_from_params,
      errors: {}
    }
  end

  def create
    authorize(Edge.new(owner: Page.new).owner, :create?)

    @page = Page.create(permit_params)
    @page.edge = Edge.new(owner: @page, user: @page.publisher)

    if @page.save
      redirect_to page_url(@page), status: 303
    else
      respond_to do |format|
        format.html do
          render 'new', locals: {
            page: @page
          }, notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}]
        end
      end
    end
  end

  def settings
    @page = Page.find_via_shortname params[:id]
    authorize @page, :update?

    render locals: {
      tab: tab,
      active: tab,
      resource: @page
    }
  end

  def update
    @page = Page.find_via_shortname params[:id]
    authorize @page, :update?

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
    @page = Page.find_via_shortname params[:id]
    authorize @page, :delete?

    respond_to do |format|
      format.html { render 'delete', locals: {resource: @page} }
      format.js { render layout: false }
    end
  end

  def destroy
    @page = Page.find_via_shortname params[:id]
    authorize @page, :destroy?
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

  def transfer
    @page = Page.find_via_shortname params[:id]
    authorize @page, :transfer?

    respond_to do |format|
      format.html { render }
      format.js { render layout: false }
    end
  end

  def transfer!
    @page = Page.find_via_shortname params[:id]
    authorize @page, :transfer?
    @new_profile = User.find_via_shortname!(params[:shortname]).profile
    unless params[:page][:confirmation_string] == t('pages.settings.managers.transfer.confirm.string')
      @page.errors.add(:confirmation_string, t('errors.messages.should_match'))
    end
    respond_to do |format|
      if @page.errors.empty? && @page.transfer_to!(@new_profile)
        reset_current_actor
        flash[:success] = t('pages.settings.managers.transferred')
        if policy(@page).update?
          format.html { redirect_to settings_page_path(@page) }
        elsif @page.forums.present?
          format.html { redirect_to forum_path(@page.forums.first) }
        else
          format.html { redirect_to(root_path) }
        end
      else
        format.html { render 'transfer', locals: {no_close: true} }
      end
    end
  end

  private

  def handle_not_authorized_error(exception)
    us_po = current_user && policy(current_user)
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
    @resource ||= Edge.new(owner: Page.new).owner
  end

  def permit_params
    return @_permit_params if defined?(@_permit_params) && @_permit_params.present?
    @_permit_params = params
                      .require(:page)
                      .permit(*policy(@page || Edge.new(owner: Page.new).owner).permitted_attributes)
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
