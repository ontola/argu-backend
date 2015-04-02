class UsersController < ApplicationController

  def show
    @user = User.preload(:profile).find_via_shortname params[:id]
    @profile = @user.profile
    authorize @profile, :show?

    if @profile.are_votes_public?
      @collection =  Vote.ordered Vote.find_by_sql('SELECT votes.*, forums.visibility FROM "votes" LEFT OUTER JOIN "forums" ON "votes"."forum_id" = "forums"."id" WHERE ("votes"."voter_type" = \'Profile\' AND "votes"."voter_id" = '+@profile.id.to_s+') AND ("votes"."voteable_type" = \'Question\' OR "votes"."voteable_type" = \'Motion\') AND ("forums"."visibility" = '+Forum.visibilities[:open].to_s+' OR "forums"."id" IN ('+ (current_profile && current_profile.memberships_ids || 0.to_s) +')) ORDER BY created_at DESC')
    end

    render 'profiles/show'
  end

  def current_actor
    @profile = current_profile
    authorize @profile, :show?

    render
  end

  def edit
    @user = current_user
    authorize @user

    unless @user.nil?
      @authentications = @user.authentications
      respond_to do |format|
        format.html
        format.json { render json: @user }
      end
    else
      flash['User not found']
      request.env['HTTP_REFERER'] ||= root_path
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render json: 'Error: user not found' }
      end
    end
  end

  # PUT /settings
  def update
    @user = User.find current_user.try :id
    authorize @user

    email_changed = @user.email != permit_params[:email]
    successfully_updated = if email_changed or !permit_params[:password].blank? or @user.invitation_token.present?
      if @user.update_with_password(permit_params)
        sign_in(@user, :bypass => true)
        UserMailer.password_changed_mail(@user)
      end
    else
      @user.update_without_password(passwordless_permit_params)
    end

    respond_to do |format|
      if successfully_updated
        format.html { redirect_to settings_path, notice: 'Wijzigingen opgeslagen.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # When shortname isn't set yet
  def setup
    @user = current_user
    @profile = current_user.profile
    authorize @user, :setup?

    render 'profiles/edit'
  end

  private
  def permit_params
    params.require(:user).permit(*policy(@user || User).permitted_attributes)
  end

  def passwordless_permit_params
    params.require(:user).permit(:follows_email, :follows_mobile,
                                 :memberships_email, :memberships_mobile,
                                 :created_email, :created_mobile)
  end
end