# frozen_string_literal: true

class BlogPostsController < EdgeableController
  include BlogPostsHelper
  skip_before_action :check_if_registered, only: :index

  private

  def default_publication_follow_type
    return super if parent_resource!.is_a?(Page)
    'news'
  end

  def index_locals
    {blog_posts: parent_resource!.blog_posts.active.page(params[:page]).reorder(created_at: :desc)}
  end

  def permit_params
    pm = super
    merge_photo_params(pm, BlogPost)
    pm
  end

  def preview_includes
    [
      :default_cover_photo,
      creator: :default_profile_photo,
      top_comment: :creator
    ]
  end

  def show_includes
    super + [
      operation: {},
      attachment_collection: inc_nested_collection,
      comment_collection: inc_shallow_collection
    ]
  end

  def show_success_html
    @comment_edges = authenticated_resource.filtered_threads(show_trashed?, params[:comments_page])
    respond_with_resource(show_success_options)
  end

  def show_view_locals
    {blog_post: authenticated_resource, comment: Comment.new}
  end
end
