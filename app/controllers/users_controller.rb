class UsersController < ApplicationController
  def index
    @users = User.all
  end
  
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    raise SecurityTransgression unless @user.clearance >= 4 || (current_user.clearance < @user.clearance)
    
    if @user.save
      if current_user.nil?
        sign_in @user
      end
      flash.now[:success] = t(:users_success_welcome) + t(:application_name) + "!"
      redirect_to @user
    else
      flash.now[:error] = t(:users_new_failed) + "!"
      render 'new'
    end
  end

  def edit
  end
 
  def update
  end

  def destroy
  end
end
