# frozen_string_literal: true

class BlogPostsController < EdgeableController
  include BlogPostsHelper
  skip_before_action :check_if_registered, only: :index

  def show
    @comment_edges = authenticated_resource.filtered_threads(show_trashed?, params[:comments_page])
    show_handler_success(authenticated_resource)
  end

  private

  def show_respond_success_html(resource)
    render locals: {blog_post: resource, comment: Comment.new}
  end

  def show_respond_success_js(resource)
    render locals: {blog_post: resource}
  end

  def update_respond_success_json(resource)
    respond_with_200(resource, :json)
  end
end
