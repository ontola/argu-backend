class Portal::ForumsController < ApplicationController
  def new
    @forum = Forum.new(page: params[:page])
    authorize @forum, :new?
  end

  def create
    @forum = Forum.new permit_params
    authorize @forum, :create?

    if @forum.save
      redirect_to portal_path
    else
      render notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}]
    end
  end

  private
  def permit_params
    params.require(:forum).permit :name, :web_url,
                                  :profile_photo, :cover_photo, :page_id
  end
end