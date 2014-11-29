class ForumsController < ApplicationController
  def show
    @forum = Forum.friendly.find params[:id]
    authorize @forum, :show?
    current_context @forum
  end



  def settings
    @forum = Forum.friendly.find params[:id]
    authorize @forum, :update?
    current_context @forum
  end

  def update
    @forum = Forum.friendly.find params[:id]
    authorize @forum, :update?

    if @forum.update permit_params
      redirect_to settings_forum_path(@forum, tab: params[:tab])
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
    params.require(:forum).permit :name, :web_url, :bio, :tags, :tag_list,
                                         {memberships_attributes: [:role, :id, :profile_id, :forum_id]}, :profile_photo, :cover_photo,
                                         :cover_photo_original_w, :cover_photo_original_h, :cover_photo_box_w, :cover_photo_crop_x, :cover_photo_crop_y, :cover_photo_crop_w, :cover_photo_crop_h, :cover_photo_aspect
  end
end
