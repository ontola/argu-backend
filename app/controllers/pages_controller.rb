class PagesController < ApplicationController

  def show
    @page = Page.find_via_shortname(params[:id])
    @profile = @page.profile
    authorize @page, :show?

    if @profile.are_votes_public?
      votes = Vote.find_by_sql('SELECT votes.*, forums.visibility FROM "votes" LEFT OUTER JOIN "forums" ON "votes"."forum_id" = "forums"."id" WHERE ("votes"."voter_type" = \'Profile\' AND "votes"."voter_id" = '+@profile.id.to_s+') AND ("votes"."voteable_type" = \'Question\' OR "votes"."voteable_type" = \'Motion\') AND ("forums"."visibility" = '+Forum.visibilities[:open].to_s+' OR "forums"."id" IN ('+ (current_profile && current_profile.memberships_ids || 0.to_s) +')) ORDER BY created_at DESC')
      @pubic_vote_count = votes.count
      @collection =  Vote.ordered votes
    end
  end

  def new
    @page = Page.new
    @page.build_shortname
    @page.build_profile
    authorize @page, :new?
  end

  def create
    @page = Page.new
    @page.build_shortname
    @page.build_profile
    @page.owner = current_user.profile
    @page.attributes= permit_params
    authorize @page, :create?

    if @page.save
      redirect_to @page
    else
      respond_to do |format|
        format.html { render 'new', notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}] }
      end
    end
  end

  def settings
    @page = Page.find_via_shortname params[:id]
    authorize @page, :update?
  end

  def update
    @page = Page.find_via_shortname params[:id]
    authorize @page, :update?

    if @page.update permit_params
      redirect_to settings_page_path(@page, tab: params[:tab])
    else
      render 'settings', tab: params[:tab]
    end
  end

  def delete
    @page = Page.find_via_shortname params[:id]
    authorize @page, :delete?

    respond_to do |format|
      format.html { render }
      format.js { render layout: false}
    end
  end

  def destroy
    @page = Page.find_via_shortname params[:id]
    authorize @page, :destroy?

    if @page.destroy
      flash[:error] = 'Pagina verwijderd'
      redirect_to root_path
    else
      flash[:error] = 'Error tijdens verwijderen'
      render :delete, locals: {resource: @page}
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
    @new_profile = Profile.find_by(id: params[:profile_id])

    respond_to do |format|
      if @new_profile.profileable_type != 'User'
        flash[:error] = t('pages.settings.managers.users_only')
        format.html { render 'transfer', locals: {no_close: true} }
      elsif @page.transfer_to!(params[:page][:repeat_name], @new_profile)
        flash[:success] = t('pages.settings.managers.transferred')
        format.html { redirect_to settings_page_path(@page) }
      else
        format.html { render 'transfer', locals: {no_close: true} }
      end
    end
  end

private
  def permit_params
    params.require(:page).permit(*policy(@page || Page).permitted_attributes)
  end
end
