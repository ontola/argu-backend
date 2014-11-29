class Portal::PagesController < ApplicationController
  def new
    @page = Page.new
    authorize @page, :new?
  end

  def create
    @page = Page.new permit_params
    @page.build_profile permit_params
    authorize @page, :create?

    if @page.save!
      redirect_to portal_path
    else
      render notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}]
    end
  end

  private
  def permit_params
    params.require(:page).permit :name, :web_url, profile_attributes: [:name, :about]
  end
end