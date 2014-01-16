class Admin::AdministrationController < ApplicationController
  respond_to :js, :html
  Admin::ROLES = %w(coder admin mod user)

  def panel
    authorize! :panel, :admin
    #Totals
    @coder_count = User.with_role(:coder).count if can? :list, :coder
    @admin_count = User.with_role(:admin).count if can? :list, :admin
    @mod_count = User.with_role(:mod).count if can? :list, :mod
    @user_count = User.with_role(:user).count if can? :list, :user
    #Own statements
    @statements = Statement.with_role(:mod, current_user)
  end

  def list
    check_role
    authorize! :list, @role
    @admins = User.with_role(@role)
  end

  # POST /admin/admin/:id
  def add
    check_role
    @user = User.find(params[:id])
    authorize! :add, @role
    @user.add_role @role
    get_count
  end

  # DELETE /admin/admin/:id
  def remove
    check_role
    @user = User.find(params[:id])
    authorize! :remove, @role
    @user.remove_role @role
    get_count
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
    @admin_count = User.with_role(:admin).count if @role == :admin
    @mod_count = User.with_role(:mod).count if @role == :mod
    @user_count = User.with_role(:user).count if @role == :user
  end

end
