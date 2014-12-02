class Tags::MotionsController < ApplicationController

  def index
    if params[:q].present?
      @tags = policy_scope(Motion).all_tags.where("lower(name) LIKE lower(?)", "%#{params[:q]}%").order(taggings_count: :desc).page params[:page]
    else
      @tags = policy_scope(Motion).all_tags.order(taggings_count: :desc).page params[:page]
    end
    authorize @tags, :index?
  end

  def show
    @tag = Tag.find_or_create_by(name: params[:tag])
    authorize @tag, :show?
    if params[:tag].present? 
      @motions = {collection: Motion.tagged_with(params[:tag])} # TODO rewrite motion to exclude where motion.tag_id
    else
      @motions = Motion.postall
    end
  end

end
