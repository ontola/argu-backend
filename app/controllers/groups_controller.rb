class GroupsController < ApplicationController

  def show
    @group = Group.find params[:id]
    authorize @group
  end

  def new
    @group = Group.new
    authorize @group
  end

  def create
    @group = Group.new permit_params
    authorize @group, :create?
    @group.group_memberships.build user: current_user, role: GroupMembership.roles[:manager]

    if @group.save
      redirect_to @group
    else
      render notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}]
    end
  end
private
  def permit_params
    params.require(:group).permit :name, :description, :slogan, :website, :public_form, :application_form,
                                         :key_tags, :profile_photo, :cover_photo,
                                         :cover_photo_original_w, :cover_photo_original_h, :cover_photo_box_w, :cover_photo_crop_x, :cover_photo_crop_y, :cover_photo_crop_w, :cover_photo_crop_h, :cover_photo_aspect
  end
end