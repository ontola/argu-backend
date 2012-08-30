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
    @user = User.find(params[:id])
      respond_to do |format|
        format.js #{ render partital: 'form' }
        format.html
      end
    
  end
 
  def update
    if signed_in?
      @user = User.find(params[:id])
      raise PermissionViolation unless @user.updatable_by?(current_user)

      respond_to do |format|
        if @user.update_attributes(params[:user])
          sign_in @user
          format.html { redirect_to :back, notice: 'User was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { redirect_to :back, notice: 'Error while updating user.' }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        flash.now[:error] = t(:application_general_not_allowed) + "!"
        format.html { redirect_to statements_url}
        format.json { head :no_content }
      end
    end
  end

  def destroy
  end

  def settings
    unless current_user.nil?
      @user = User.find(params[:id])
      @tab = params[:tab]
    
      raise PermissionViolation unless @user.id == current_user.id

      respond_to do |format|
        format.html
      end
    else
      redirect_to root_path
    end
  end

  def settingsUpdate
    unless current_user.nil?
      current_user.settings.locale = params['locale']
    end
    respond_to do |format|
      unless current_user.nil?
        @success = true;
        format.js
      else
        @success = false;
        format.js
      end
    end
  end
end
