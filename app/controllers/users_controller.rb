class UsersController < ApplicationController
  def show
    @user = User.preload(:profile).find_via_shortname params[:id]
    @profile = @user.profile
    authorize @user, :show?

    if @profile.are_votes_public? || current_user == @user
      @collection = Vote.ordered Vote.find_by_sql(voted_select_query).reject { |v| v.voteable.is_trashed? }
    end

    respond_to do |format|
      format.html { render 'profiles/show' }
    end
  end

  def current_actor
    @profile = current_profile
    authorize @profile.profileable, :show?

    render
  end

  def settings
    get_user_or_redirect(settings_path)
    authorize @user

    @user.build_home_placement if @user.home_placement.nil?

    if @user.present?
      prepend_view_path 'app/views/users'

      render 'settings', locals: {tab: tab, active: tab, profile: @user.profile}
    else
      flash[:error]= 'User not found'
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

    email_changed = permit_params[:email].present? && @user.email != permit_params[:email]
    successfully_updated =
      if email_changed || permit_params[:password].present? || @user.invitation_token.present?
        if @user.update_with_password(permit_params)
          sign_in(@user, bypass: true)
          UserMailer.delay.user_password_changed(@user) if @user.valid_password?(permit_params[:password])
          true
        end
      else
        @user.update_without_password(passwordless_permit_params)
      end
    respond_to do |format|
      if successfully_updated
        notice = if email_changed
                   t('users.registrations.confirm_mail_change_notice')
                 else
                   t('type_save_success', type: t('type_changes'))
                 end
        format.html { redirect_to settings_path(tab: tab), notice: notice }
        format.json { head :no_content }
      else
        format.html do
          prepend_view_path 'app/views/users'
          render 'settings', locals: {tab: tab, active: tab, profile: @user.profile}
        end
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def connect
    payload = decode_token params[:token]
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
    payload = decode_token params[:token]
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
    @user.build_shortname if @user.shortname.blank?

    render 'setup_shortname', layout: 'closed'
  end

  def setup!
    get_user_or_redirect
    authorize @user, :setup?
    if current_user.url.blank?
      current_user.build_shortname shortname: params[:user][:shortname_attributes][:shortname]

      if current_user.save
        if current_user.finished_intro?
          flash[:success] = t('devise.registrations.signed_up')
          if current_user.r.present?
            r = URI.decode(current_user.r)
            current_user.update r: ''
          end
        end
        redirect_to r.presence || root_path
      else
        render 'setup_shortname'
      end
    else
      flash[:success] = t('users.shortname.not_changeable')
      redirect_to root_path
    end
  end

  def tab
    policy(@user || User).verify_tab(params[:tab] || params[:user].try(:[], :tab))
  end

  def language
    authorize :static_page, :home?
    locale = permit_locale_params
    if I18n.available_locales.include?(locale.to_sym)
      success =
        if current_user.blank?
          cookies['locale'] = locale
        else
          current_user.update(language: locale)
        end

      respond_to do |format|
        flash[:error] = t('errors.general') unless success.present?
        format.html { redirect_to :back }
      end
    else
      Bugsnag.notify(RuntimeError.new("Invalid locale #{params[:locale]} (#{locale})"))
      flash[:error] = t('errors.general')
      redirect_to :back
    end
  end

  private

  def get_user_or_redirect(redirect = nil)
    @user = current_user
    if current_user.blank?
      flash[:error] = t('devise.failure.unauthenticated')
      raise Argu::NotAUserError.new(r: redirect)
    end
  end

  def permit_locale_params
    params.require(:locale)
  end

  def permit_params
    pp = params.require(:user).permit(*policy(@user || User).permitted_attributes(true))
    merge_photo_params(pp, @user.class)
    merge_placement_params(pp, User)
    pp
  end

  def passwordless_permit_params
    pp = params.require(:user).permit(*policy(@user || User).permitted_attributes)
    merge_photo_params(pp, @user.class)
    merge_placement_params(pp, User)
    pp
  end

  def voted_select_query
    'SELECT votes.*, forums.visibility FROM "votes" LEFT OUTER JOIN "forums" ON "votes"."forum_id" = "forums"."id" '\
      'WHERE "votes"."voter_id" = '+@profile.id.to_s+' AND '\
      '("votes"."voteable_type" = \'Question\' OR "votes"."voteable_type" = \'Motion\') AND '\
      '("forums"."visibility" = '+Forum.visibilities[:open].to_s+' OR '\
      '"forums"."id" IN ('+ (current_profile && current_profile.joined_forum_ids || 0.to_s) +')) '\
      'ORDER BY created_at DESC'
  end
end
