class AdministrationController < ApplicationController
  respond_to :js, :html

  # POST /admin/:id
  def add
    @user = User.find(params[:id])
    authorize! :add_admin, @user

    respond_to do |format|
      if !@user.frozen? && @user.add_role(:administration)
        format.js
      else
        format.js { head 400 }
      end
    end
  end

  # DELETE /admin/:id
  def remove
    @user = User.find(params[:id])
    authorize! :remove_admin, @user
    @user.remove_role :administration
    respond_to do |format|
      format.js { render 'add'}
    end
  end

  # POST /admin/freeze/:id
  def freeze
    @user = User.find_by_id params[:id]
    authorize! :freeze, @user
    @user.freeze
    respond_to do |format|
      format.js
    end
  end

  # DELETE /admin/freeze/:id
  def unfreeze
    @user = User.find_by_id params[:id]
    authorize! :unfreeze, @user
    @user.unfreeze
    respond_to do |format|
      format.js { render 'freeze'}
    end
  end

private
  def check_role
    if params[:role]
      @role = params[:role].to_sym
    else
      head 400
    end
  end

  def get_count
    @coder_count = User.with_role(:coder).count if @role == :coder
    @admin_count = User.with_role(:administration).count if @role == :administration
    @mod_count = User.with_role(:mod).count if @role == :mod
    @user_count = User.with_role(:user).count if @role == :user
  end

end
