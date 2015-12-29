class ProjectsController < ApplicationController
  before_action :show, :redirect_pages

  def new
  end

  def show
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def delete
  end

private

  def redirect_pages
    if params[:id].to_i == 0
      redirect_to page_path(params[:id])
    end
  end
end
