class GroupsController < ApplicationController
  def new
    @group = Group.new
    authorize @group
  end
end