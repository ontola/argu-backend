class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      #render 'new'
    else
      flash[:error] = 'Invalid email or password'
      render 'new'
    end
  end

  def destroy
  end


end
