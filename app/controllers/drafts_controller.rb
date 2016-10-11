# frozen_string_literal: true
class DraftsController < ApplicationController
  def index
    @user = User.find_via_shortname params[:id]

    projects = policy_scope(@user.projects.unpublished.trashed(false))
    blog_posts = policy_scope(@user.blog_posts.unpublished.trashed(false))
    if policy(@user).show?
      @items = Kaminari
               .paginate_array((projects + blog_posts)
                                   .sort_by(&:updated_at)
                                   .reverse)
               .page(show_params[:page])
               .per(30)
    end
  end

  private

  def show_params
    params.permit(:page)
  end
end
