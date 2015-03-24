class TagsController < ApplicationController

  def show
    @forum = Forum.find_via_shortname params[:forum_id]
    authorize @forum, :show?
    @tag = Tag.find(name: params[:id])

    @collection = (Motion.tagged_with(params[:id]).where(forum_id: @forum.id).trashed(show_trashed?).concat(Question.tagged_with(params[:id]).where(forum_id: @forum.id).trashed(show_trashed?))).sort_by(&:created_at).reverse

    @collection = {collection: @collection} # TODO rewrite motion to exclude where motion.tag_id

    respond_to do |format|
      format.html
      format.json
    end
  end

end
