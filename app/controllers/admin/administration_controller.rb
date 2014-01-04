class Admin::AdministrationController < ApplicationController
  respond_to :js, :html
  def panel
    @admin_count = User.with_role(:admin).count
  end

  def list
    @admins = User.with_role(:admin)
  end

  def add

  end

end
