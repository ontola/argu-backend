# frozen_string_literal: true
class DraftsController < ApplicationController
  def index
    @user = User.find_via_shortname! params[:id]
    authorize @user, :edit?

    blog_posts = BlogPost.where(creator_id: @user.managed_profile_ids).unpublished.untrashed
    motions = Motion.where(creator_id: @user.managed_profile_ids).unpublished.untrashed
    questions = Question.where(creator_id: @user.managed_profile_ids).unpublished.untrashed
    @items = Kaminari
             .paginate_array((blog_posts + motions + questions)
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
