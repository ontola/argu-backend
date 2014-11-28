class CommentsController < ApplicationController

  def show
  end

  # POST /resource/1/comments
  def create
    resource = get_commentable
    @comment = Comment.build_from(resource, current_profile.id, params[:comment])
    authorize @comment
    parent = Comment.find_by_id params[:parent_id] unless params[:parent_id].blank?
    #unless params[:parent_id].blank?
    #  #@TODO Just let them go nuts for now, infinite parenting
    #  @comment.move_to_child_of Comment.find_by_id params[:parent_id]
    #end

    respond_to do |format|
      if (parent.present? ? (@comment.move_possible?(parent) && @comment.move_to_child_of(parent)) : true) && @comment.save!
        format.html { redirect_to polymorphic_url([resource], anchor: @comment.id), notice: t('type_create_success', type: t('comments.type')) }
      else
        #@comment.destroy unless @comment.new_record? # TODO: this shit deletes all comments, so thats not really a great thing..
        format.html { redirect_to polymorphic_url([resource], anchor: @comment.id), notice: '_niet gelukt_' }
      end
    end
  end

  def update
  end

  # DELETE /arguments/1/comments/1
  def destroy
    @comment = Comment.find_by_id params[:id]
    resource = @comment.commentable
    if params[:destroy] == 'true'
      authorize @comment
      @comment.destroy
    else
      authorize @comment, :trash?
      @comment.trash
    end
    respond_to do |format|
      format.html { redirect_to polymorphic_url([resource], anchor: @comment.id) }
      format.js # destroy_comment.js
    end
  end

private
  def get_commentable
    resource, id = request.path.split('/')[1,2]
    return resource.singularize.classify.constantize.find(id)
  end

end
