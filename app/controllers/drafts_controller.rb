# frozen_string_literal: true
class DraftsController < ApplicationController
  def index
    @user = User.find_via_shortname params[:id]

    projects = @user.projects.unpublished.trashed(false)
    blog_posts = @user.blog_posts.unpublished.trashed(false)
    return unless policy(@user).show?
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
