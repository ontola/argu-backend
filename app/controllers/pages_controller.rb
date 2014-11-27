class PagesController < ApplicationController
  def show
    @profile = Page.friendly.find(params[:id]).profile
    authorize @profile, :show?

    @collection =  Vote.ordered @profile.votes

    render 'profiles/show'
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
  end

  def destroy
  end

private
  def permit_params
    params.require(:page).permit :name
  end
end
