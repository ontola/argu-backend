class ProfilesController < ApplicationController

  def index
    authorize Profile, :index?
    scope = policy_scope(Profile)

    if params[:q].present?
      @profiles = scope.where('lower(name) LIKE lower(?)', "%#{params[:q]}%").page params[:profile]
    end
  end

  #GET /1/edit
  def edit
    @user = User.find_via_shortname(params[:id])
    @profile = @user.profile
    authorize @profile, :edit?

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
    @user = User.find_via_shortname(params[:id])
    @profile = @user.profile
    authorize @profile, :update?

    updated = nil
    Profile.transaction do
      updated = @profile.update_attributes(permit_params)

      if (!@user.finished_intro?) && has_valid_token?(@user)
        @user.update finished_intro: true
        get_access_tokens(@user).each do |at|
          @profile.memberships.create(forum: at.item) if at.item.class == Forum
        end
      end
    end
    respond_to do |format|
      if updated && @user.r.present?
        r = @user.r
        @user.update r: ''
        format.html { redirect_to r,
                      status: r.match(/\/v(\?|\/)|\/c(\?|\/)/) ? 307 : 302 }
      elsif updated
        format.html { redirect_to dual_profile_path(@profile), notice: 'Profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

private
  def permit_params
    params.require(:profile).permit :name, :about, :profile_photo, :are_votes_public
  end

  def profile_update_path
    @user.finished_intro? ? profile_path(@user.url) : selector_forums_path
  end
end
