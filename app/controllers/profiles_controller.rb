class ProfilesController < ApplicationController

  #GET /profiles/1
  def show
    @profile = User.find_by(username: params[:id]).profile
    raise ActiveRecord::RecordNotFound if @profile.blank?
    authorize @profile, :show?

    # TODO: Refactor into arel or something..
    @collection =  Vote.ordered Vote.find_by_sql('SELECT votes.*, forums.visibility FROM "votes" LEFT OUTER JOIN "forums" ON "votes"."forum_id" = "forums"."id" WHERE ("votes"."voter_type" = \'Profile\' AND "votes"."voter_id" = '+@profile.id.to_s+') AND ("votes"."voteable_type" = \'Question\' OR "votes"."voteable_type" = \'Motion\') AND ("forums"."visibility" = '+Forum.visibilities[:open].to_s+' OR "forums"."id" IN ('+ (current_profile.memberships.pluck(:forum_id).join(',').presence || 0.to_s) +'))')

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  #GET /1/edit
  def edit
    @user = User.find_by(username: params[:id])
    @profile = @user.profile
    authorize @profile

    if @user.finished_intro?
      respond_to do |format|
        format.html # edit.html.erb
      end
    else
      respond_to do |format|
        format.html { render layout: 'closed' } # edit.html.erb
      end
    end
  end

  #PUT /1
  def update
    @user = User.find_by(username: params[:id])
    @profile = @user.profile
    authorize @profile

    respond_to do |format|
      if @profile.update_attributes permit_params
        format.html { redirect_to profile_update_path, notice: "Profile was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

private
  def permit_params
    params.require(:profile).permit :name, :about, :profile_photo
  end

  def profile_update_path
    @user.finished_intro? ? profile_path(@user.username) : selector_forums_path
  end
end
