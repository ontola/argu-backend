class AuthenticationsController < ApplicationController

  def create
    omniauth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      flash[:notice] = t('users_oauth_notices_signedin')
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      flash[:notice] = t('users_oauth_notices_linked')
      redirect_to authentications_url
    else
      omniauth['info']['nickname'] = User.is_valid_username?(omniauth['info']['nickname']) ? omniauth['info']['nickname'] : ('u'+'%010d' % rand(10 ** 10)).to_s
      user = User.create(username: omniauth['info']['nickname'],
                         email: omniauth['info']['email'],
                         profile: Profile.create(name: omniauth['info']['name'],
                                                 picture: omniauth['info']['image']),
                         :password => Devise.friendly_token[0,20])
      user.apply_omniauth(omniauth)
      if user.save
        flash[:notice] = t('users_oauth_notices_signedin')
        sign_in(:user, user)
        redirect_to edit_user_registration_path
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_url
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    #Check if auth was the last linked account, if so, delete the user
    if current_user.authentications.empty? && current_user.email.blank? && current_user.username.blank?
      current_user.destroy
      redirect_to root_url, :notice => t('users_oauth_notices_deleted')
    else
      redirect_to authentications_url, :notice => t('users_oauth_notices_linked')
    end
  end
end
