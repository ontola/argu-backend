# frozen_string_literal: true
class Users::IdentitiesController < AuthorizedController
  include RedisResourcesHelper
  skip_before_action :check_if_registered, only: [:connect, :connect!]

  def destroy
    respond_to do |format|
      if authenticated_resource.destroy
        flash[:success] = t('devise.authentications.destroyed')
      else
        flash[:error] = t('devise.authentications.destroyed_failed')
      end
      format.html { redirect_to settings_user_path }
    end
  end

  def connect
    user = User.find_via_shortname! params[:id]

    render locals: {
      identity: authenticated_resource,
      user: user,
      token: params[:token]
    }
  end

  def connect!
    user = User.find_via_shortname! params[:id].presence || params[:user][:id]
    user.r = r_param
    schedule_redis_resource_worker(GuestUser.new(id: session.id), user, r_param)
    setup_favorites(user)

    if authenticated_resource.email == user.email && user.valid_password?(params[:user][:password])
      # Connect user to identity
      authenticated_resource.user = user
      if authenticated_resource.save
        flash[:success] = 'Account connected'
        sign_in user
        redirect_with_r(user)
      else
        render 'users/identities/connect',
               locals: {
                 identity: authenticated_resource,
                 user: user,
                 token: params[:token]
               }
      end
    else
      user.errors.add(:password, t('errors.messages.invalid'))
      render 'users/identities/connect',
             locals: {
               identity: authenticated_resource,
               user: user,
               token: params[:token]
             }
    end
  end

  private

  def authenticated_tree; end

  def resource_id
    return super unless %w(connect connect!).include?(action_name)
    payload = decode_token params[:token]
    @identity = Identity.find payload['identity']
  end
end
