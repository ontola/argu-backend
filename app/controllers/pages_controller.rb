class PagesController < ApplicationController

  def index
    authorize Page, :index?
    scope = policy_scope(Page).includes(:profile)

    if params[:q].present?
      @pages = scope.where('lower(web_url) LIKE lower(?)', "%#{params[:q]}%").page params[:page]
    end
  end

  def show
    @page = Page.friendly.find(params[:id])
    @profile = @page.profile
    authorize @page, :show?

    @collection =  Vote.ordered @profile.votes
  end

  def new
    @page = Page.new
    authorize @page, :new?
  end

  def create
    @page = Page.new permit_params
    authorize @page, :create?
    @page.build_profile permit_params
    @page.owner = current_user.profile

    if @page.save!
      redirect_to @page
    else
      render notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}]
    end
  end

  def settings
    @page = Page.friendly.find params[:id]
    authorize @page, :update?
  end

  def update
    @page = Page.friendly.find params[:id]
    authorize @page, :update?

    if @page.update permit_params
      redirect_to settings_page_path(@page, tab: params[:tab])
    else
      render 'settings'
    end
  end

  def delete
    @page = Page.friendly.find params[:id]
    authorize @page, :delete?

    respond_to do |format|
      format.html { render }
      format.js { render layout: false}
    end
  end

  def destroy
    @page = Page.friendly.find params[:id]
    authorize @page, :destroy?

    if @page.destroy
      flash[:error] = 'Pagina verwijderd'
      redirect_to root_path
    else
      flash[:error] = 'Error tijdens verwijderen'
      render :delete, locals: {resource: @page}
    end

  end

private
  def permit_params
    params.require(:page).permit(*policy(@page || Page).permitted_attributes)
  end
end
