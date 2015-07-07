class UsersController < ApplicationController

  def show
    @user = User.preload(:profile).find_via_shortname params[:id]
    @profile = @user.profile
    authorize @profile, :show?

    if @profile.are_votes_public?
      @collection = Vote.ordered Vote.find_by_sql('SELECT votes.*, forums.visibility FROM "votes" LEFT OUTER JOIN "forums" ON "votes"."forum_id" = "forums"."id" WHERE ("votes"."voter_type" = \'Profile\' AND "votes"."voter_id" = '+@profile.id.to_s+') AND ("votes"."voteable_type" = \'Question\' OR "votes"."voteable_type" = \'Motion\') AND ("forums"."visibility" = '+Forum.visibilities[:open].to_s+' OR "forums"."id" IN ('+ (current_profile && current_profile.memberships_ids || 0.to_s) +')) ORDER BY created_at DESC').reject { |v| v.voteable.is_trashed? }
    end

    render 'profiles/show'
  end

  def current_actor
    @profile = current_profile
    authorize @profile, :show?

    render
  end

  def edit
    get_user_or_redirect
    authorize @user

    if @user.present?
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
        format.html { redirect_to settings_path }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def connect
    payload = decrypt_token params[:token]
    identity = Identity.find payload['identity']
    user = User.find_via_shortname! params[:id]

    skip_authorization
    render locals: {
               identity: identity,
               user: user,
               token: params[:token]
           }
  end

  def connect!
    user = User.find_via_shortname! params[:id].presence || params[:user][:id]
    payload = decrypt_token params[:token]
    @identity = Identity.find payload['identity']

    skip_authorization
    if @identity.email == user.email && user.valid_password?(params[:user][:password])
      # Connect user to identity
      @identity.user = user
      if @identity.save
        flash[:success] = 'Account connected'
        sign_in_and_redirect user
      else
        render 'users/connect',
               locals: {
                 identity: @identity,
                 user: user,
                 token: params[:token]
               }
      end
    else
      user.errors.add(:password, t('errors.messages.invalid'))
      render 'users/connect',
             locals: {
               identity: @identity,
               user: user,
               token: params[:token]
             }
    end
  end

  # When shortname isn't set yet
  def setup
    get_user_or_redirect
    authorize @user, :setup?
    if @user.shortname.blank?
      @user.build_shortname
    end

    render 'setup_shortname', layout: 'closed'
  end

  def setup!
    get_user_or_redirect
    authorize @user, :setup?
    if current_user.url.blank?
      current_user.build_shortname shortname: params[:user][:shortname_attributes][:shortname]

      if current_user.save
        flash[:success] = t('devise.registrations.signed_up') if current_user.finished_intro?
        redirect_to root_path
      else
        render 'setup_shortname'
      end
    else
      flash[:success] = t('users.shortname.not_changeable')
      redirect_to root_path
    end
  end

  private
  def get_user_or_redirect
    @user = current_user
    if current_user.blank?
      flash[:error] = t('devise.failure.unauthenticated')
      redirect_to :back
    end
  end

  def permit_params
    params.require(:user).permit(*policy(@user || User).permitted_attributes(true))
  end

  def passwordless_permit_params
    params.require(:user).permit(*policy(@user || User).permitted_attributes)
  end
end
