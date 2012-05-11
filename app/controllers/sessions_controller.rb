class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      sign_in user
      if user.email.eql?("thom@wthex.com")
        I18n.locale = :nl
      end
      redirect_to home_path
    else
      flash.now[:error] = t(:sessions_error_invalid)
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end


end
