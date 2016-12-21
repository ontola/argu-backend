# frozen_string_literal: true
class DraftsController < ApplicationController
  def index
    @user = User.find_via_shortname params[:id]
    authorize @user, :edit?

    projects = @user.projects.unpublished.untrashed
    blog_posts = @user.blog_posts.unpublished.untrashed
    @items = Kaminari
             .paginate_array((projects + blog_posts)
                                 .sort_by(&:updated_at)
                                 .reverse)
             .page(show_params[:page])
             .per(30)
  end

  private

  def show_params
    params.permit(:page)
  end
end
