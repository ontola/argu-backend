class TagsController < ApplicationController

  def index
    if params[:q].present?
      @tags = policy_scope(Motion).all_tags.where("lower(name) LIKE lower(?)", "%#{params[:q]}%").order(taggings_count: :desc).page params[:page]
    else
      @tags = policy_scope(Motion).all_tags.order(taggings_count: :desc).page params[:page]
    end
    authorize @tags, :index?
  end

  def show
    @tag = Tag.find_or_create_by(name: params[:id])
    authorize @tag, :show?

    @collection = (Motion.tagged_with(params[:id]).concat(Question.tagged_with(params[:id]))).sort_by(&:created_at).reverse

    if params[:id].present?
      @motions = {collection: @collection } # TODO rewrite motion to exclude where motion.tag_id
    else
      @motions = Motion.postall
    end

    respond_to do |format|
      format.html
      format.json
    end
  end

end
