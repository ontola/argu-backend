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
    if @user.save
      sign_in @user
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
