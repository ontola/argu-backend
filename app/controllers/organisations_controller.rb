class OrganisationsController < ApplicationController
  def show
    @org = Organisation.find params[:id]
    authorize @org, :show?
  end

  def new
    @org = Organisation.new
    authorize @org, :new?
  end

  def create
    @org = Organisation.new permit_params
    authorize @org, :create?
    @org.memberships.build user: current_user, role: Membership.roles.manager

    if @org.save
      redirect_to @org
    else
      render notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}]
    end
  end

  def settings
    @org = Organisation.find params[:id]
    authorize @org, :update?
  end

  def update
    @org = Organisation.find params[:id]
    authorize @org, :update?

    if @org.update permit_params
      render 'settings'
    else
      render notifications: [{type: 'error', message: 'Fout tijdens het opslaan'}]
    end
  end

  def delete
  end

  def destroy
  end

private
  def permit_params
    params.require(:organisation).permit :name, :web_url, :description, :slogan, :website, :public_form, :organisation_form,
                                         :key_tags, :profile_photo, :cover_photo,
                                         :cover_photo_original_w, :cover_photo_original_h, :cover_photo_box_w, :cover_photo_crop_x, :cover_photo_crop_y, :cover_photo_crop_w, :cover_photo_crop_h, :cover_photo_aspect
  end
end
