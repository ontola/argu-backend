class UsersController < ApplicationController
  def index
    @users = User.all

    respond_to do |format|
      format.html
      format.json { render json: @users }
    end
  end
  
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end

  def new
    @user = User.new

    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end

  def create
    @user = User.new(params[:user])
    @user.clearance = (@user.clearance.nil? || @user.clearance == 0) ? 4 : @user.clearance
    raise PermissionViolation unless @user.user_creatable_by?(current_user)
    
    if @user.save
      if current_user.nil?
        sign_in @user
      end
      flash.now[:success] = t(:users_success_welcome) + t(:application_name) + "!"
      respond_to do |format|
        format.html { redirect_to @user }
        format.json { render json: @user }
      end
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
