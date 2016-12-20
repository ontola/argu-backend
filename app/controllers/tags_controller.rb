# frozen_string_literal: true
class TagsController < ApplicationController
  def index
    @forum = if params[:forum_id].present?
               Forum.find_via_shortname params[:forum_id]
             else
               taggable_class.find(params[taggable_type]).try(:forum)
             end
    authorize @forum, :show?

    if params[:q].present?
      @tags = policy_scope(Motion)
              .all_tags
              .where('lower(name) LIKE lower(?)', "%#{params[:q]}%")
              .order(taggings_count: :desc)
              .page params[:page]
    else
      @tags = policy_scope(Motion).all_tags.order(taggings_count: :desc).page params[:page]
    end
  end

  def show
    @forum = Forum.find_via_shortname params[:forum_id]
    authorize @forum, :show?
    @tag = Tag.find_by!(name: params[:id])

    @collection = Motion.tagged_with(params[:id])
                        .where(forum_id: @forum.id)
                        .show_trashed(show_trashed?)
                        .concat(Question
                               .tagged_with(params[:id])
                               .where(forum_id: @forum.id)
                               .show_trashed(show_trashed?))
                        .sort_by(&:created_at)
                        .reverse

    @collection = {collection: @collection} # TODO: rewrite motion to exclude where motion.tag_id

    respond_to do |format|
      format.html
      format.json
    end
  end

  private

  def taggable_param
    request.path_parameters.keys.find { |k| /_id/ =~ k }
  end

  def taggable_type
    taggable_param[0..-4]
  end

  # Note: Safe to constantize since `path_parameters` uses the routes for naming.
  def taggable_class
    taggable_type.capitalize.constantize
  end
end
