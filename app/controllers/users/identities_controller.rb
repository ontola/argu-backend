# frozen_string_literal: true

class Users::IdentitiesController < AuthorizedController
  include RedisResourcesHelper
  skip_before_action :check_if_registered, only: %i[connect connect!]

  def connect
    user = User.find_via_shortname_or_id! params[:id]

    render locals: {
      identity: authenticated_resource,
      user: user,
      token: params[:token]
    }
  end

  def connect!
    user = User.find_via_shortname_or_id! params[:id].presence || params[:user][:id]
    user.r = r_param
    schedule_redis_resource_worker(GuestUser.new(id: session_id), user, r_param)
    setup_favorites(user)
    if connection_valid?(user)
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

  def connection_valid?(user)
    user.email_addresses.where(email: authenticated_resource.email).exists? &&
      user.valid_password?(params[:user][:password])
  end

  def redirect_model_success(_resource)
    settings_user_path(tab: :authentication)
  end

  def resource_by_id
    return super unless %w[connect connect!].include?(action_name)
    payload = decode_token params[:token]
    @identity = Identity.find payload['identity']
  end
end
