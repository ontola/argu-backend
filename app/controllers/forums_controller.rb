class ForumsController < ApplicationController
  def show
    @org = Forum.friendly.find params[:id]
    authorize @org, :show?
  end



  def settings
    @forum = Forum.friendly.find params[:id]
    authorize @forum, :update?
  end

  def update
    @org = Forum.friendly.find params[:id]
    authorize @org, :update?

    if @org.update permit_params
      redirect_to settings_organisation_path(@org, tab: params[:tab])
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
    params.require(:forum).permit :name, :web_url, :description, :slogan, :website, :public_form, :organisation_form,
                                         {memberships_attributes: [:role, :id, :user_id]}, :key_tags, :profile_photo, :cover_photo,
                                         :cover_photo_original_w, :cover_photo_original_h, :cover_photo_box_w, :cover_photo_crop_x, :cover_photo_crop_y, :cover_photo_crop_w, :cover_photo_crop_h, :cover_photo_aspect
  end
end
