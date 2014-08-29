class Tags::StatementsController < ApplicationController

  def index
    if params[:q].present?
      @tags = policy_scope(Statement).all_tags.where("lower(name) LIKE lower(?)", "%#{params[:q]}%").order(taggings_count: :desc).page params[:page]
    else
      @tags = policy_scope(Statement).all_tags.order(taggings_count: :desc).page params[:page]
    end
  end

  def show
    @tag = Tag.find_by_name(params[:tag])
    if params[:tag].present? 
      @statements = Statement.tagged_with(params[:tag]) # TODO rewrite statement to exclude where statement.tag_id
    else
      @statements = Statement.postall
    end
    authorize @tag
  end

end
