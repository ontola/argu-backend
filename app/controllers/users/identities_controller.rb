# frozen_string_literal: true
class Users::IdentitiesController < ApplicationController
  def destroy
    @identity = Identity.find params[:id]
    authorize @identity, :destroy?

    respond_to do |format|
      if @identity.destroy
        flash[:success] = t('devise.authentications.destroyed')
      else
        flash[:error] = t('devise.authentications.destroyed_failed')
      end
      format.html { redirect_to settings_user_path }
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
    user.r = r_param
    setup_favorites(user)

    payload = decode_token params[:token]
    @identity = Identity.find payload['identity']

    skip_authorization
    if @identity.email == user.email && user.valid_password?(params[:user][:password])
      # Connect user to identity
      @identity.user = user
      if @identity.save
        flash[:success] = 'Account connected'
        sign_in user
        redirect_with_r(user)
      else
        render 'users/identities/connect',
               locals: {
                 identity: @identity,
                 user: user,
                 token: params[:token]
               }
      end
    else
      user.errors.add(:password, t('errors.messages.invalid'))
      render 'users/identities/connect',
             locals: {
               identity: @identity,
               user: user,
               token: params[:token]
             }
    end
  end
end
