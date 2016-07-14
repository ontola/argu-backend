class PagesController < ApplicationController
  def index
    authorize Page, :index?
    @user = User.find_via_shortname params[:id]
    authorize @user,:update?
    @pages = Page
               .where(id: @user.profile.pages.pluck(:id)
                            .concat(@user.profile.page_ids(:manager)))
               .distinct
    @_pundit_policy_scoped = true

    render locals: {
      current: current_user.profile.pages.length,
      max: policy(Page).max_allowed_pages
    }
  end

  def show
    @page = Page.find_via_shortname(params[:id])
    @profile = @page.profile
    authorize @page, :show?

    if @profile.are_votes_public?
      votes = Vote.find_by_sql(voted_select_query)
      @pubic_vote_count = votes.count
      @collection = Vote.ordered votes
    end

    render 'profiles/show'
  end

  def new
    authorize Page, :new?

    pa_po = policy(Page)
    errors = {}
    if pa_po.create?
      page = Page.new
      page.build_shortname
      page.build_profile
    else
      if pa_po.max_pages_reached?
        errors[:max_allowed_pages] = {
            max: pa_po.max_allowed_pages,
            current: current_user.profile.pages.length,
            pages_url: pages_user_url(current_user)
        }
      end
    end

    render locals: {
      page: page,
      errors: errors
    }
  end

  def create
    authorize Page, :create?

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
      format.js { render layout: false}
    end
  end

  def destroy
    @page = Page.find_via_shortname params[:id]
    authorize @page, :destroy?

    if @page.destroy
      redirect_to root_path, notice: t('type_destroy_success', type: t('pages.type'))
    else
      format.html { redirect_to motion, notice: t('errors.general') }
    end
  end

  def transfer
    @page = Page.find_via_shortname params[:id]
    authorize @page, :transfer?

    respond_to do |format|
      format.html { render }
      format.js { render layout: false}
    end
  end

  def transfer!
    @page = Page.find_via_shortname params[:id]
    authorize @page, :transfer?
    @new_profile = User.find_via_shortname!(params[:shortname]).profile

    respond_to do |format|
      if @page.transfer_to!(params[:page][:repeat_name], @new_profile)
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

  def permit_params
    return @_permit_params if defined?(@_permit_params) && @_permit_params.present?
    @_permit_params = params.require(:page).permit(*policy(@page || Page).permitted_attributes)
                        .merge(owner: current_user.profile)
    merge_photo_params(@_permit_params, Page)
    @_permit_params[:last_accepted] = DateTime.current if permit_params[:last_accepted] == '1'
    @_permit_params
  end

  def tab
    @tab ||= policy(@page || Page).verify_tab(params[:tab])
  end

  def voted_select_query
    'SELECT votes.*, forums.visibility FROM "votes" LEFT OUTER JOIN "forums" ON "votes"."forum_id" = "forums"."id" '\
      'WHERE ("votes"."voter_type" = \'Profile\' AND '\
      '"votes"."voter_id" = ' + @profile.id.to_s + ') AND '\
      '("votes"."voteable_type" = \'Question\' OR "votes"."voteable_type" = \'Motion\') '\
      'AND ("forums"."visibility" = ' + Forum.visibilities[:open].to_s + ' OR '\
      '"forums"."id" IN ('+ (current_profile && current_profile.joined_forum_ids || 0.to_s) +')) '\
      'ORDER BY created_at DESC'
  end
end
