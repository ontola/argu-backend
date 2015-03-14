class Portal::PagesController < ApplicationController

  def destroy
    @page = Page.friendly.find params[:id]
    authorize @page, :destroy?

    if @page.destroy!
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js { render json: {notifications: [{type: 'error', message: '_Kon pagina niet verwijderen_'}]} }
      end
    end
  end

  private
  def permit_params
    params.require(:page).permit :name, :web_url, profile_attributes: [:name, :about]
  end
end