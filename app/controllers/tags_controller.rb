class TagsController < ApplicationController

  def index
    if params[:motion_id].present?
      @forum = Motion.find(params[:motion_id]).forum
    elsif params[:question_id].present?
      @forum = Motion.find(params[:question_id]).forum
    else
      @forum = Forum.find_via_shortname params[:forum_id]
    end
    authorize @forum, :show?

    if params[:q].present?
      @tags = policy_scope(Motion).all_tags.where("lower(name) LIKE lower(?)", "%#{params[:q]}%").order(taggings_count: :desc).page params[:page]
    else
      @tags = policy_scope(Motion).all_tags.order(taggings_count: :desc).page params[:page]
    end
  end

  def show
    @forum = Forum.find_via_shortname params[:forum_id]
    authorize @forum, :show?
    @tag = Tag.find_by!(name: params[:id])

    @collection = (Motion.tagged_with(params[:id]).where(forum_id: @forum.id).trashed(show_trashed?).concat(Question.tagged_with(params[:id]).where(forum_id: @forum.id).trashed(show_trashed?))).sort_by(&:created_at).reverse

    @collection = {collection: @collection} # TODO rewrite motion to exclude where motion.tag_id

    respond_to do |format|
      format.html
      format.json
    end
  end

end
