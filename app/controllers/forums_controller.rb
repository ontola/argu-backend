class ForumsController < ApplicationController
  def show
    @forum = Forum.friendly.find params[:id]
    authorize @forum, :show?
    current_context @forum
  end



  def settings
    @forum = Forum.friendly.find params[:id]
    authorize @forum, :update?
    current_context @forum
  end

  def statistics
    @forum = Forum.friendly.find params[:id]
    authorize @forum, :statistics?

    @tags = []
    tag_ids = Tagging.where(forum_id: @forum.id).select(:tag_id).distinct.map(&:tag_id)
    tag_ids.each do |tag_id|
      taggings = Tagging.where(forum_id: @forum.id, tag_id: tag_id)
      @tags << {name: Tag.find(taggings.first.tag_id).name, count: taggings.length}
    end
    @tags = @tags.sort  { |x,y| y[:count] <=> x[:count] }
  end

  def update
    @forum = Forum.friendly.find params[:id]
    authorize @forum, :update?

    if @forum.update permit_params
      redirect_to settings_forum_path(@forum, tab: params[:tab])
    else
      render 'settings'
    end
  end

  def delete
  end

  def destroy
  end

private
  def permit_params
    params.require(:forum).permit(*policy(@forum || Forum).permitted_attributes)
  end
end
