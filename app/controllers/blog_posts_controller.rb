# frozen_string_literal: true

class BlogPostsController < EdgeTreeController
  include BlogPostsHelper
  skip_before_action :check_if_registered, only: :index

  def show
    @comment_edges = authenticated_resource.filtered_threads(show_trashed?, params[:comments_page])
    respond_to do |format|
      format.html { render locals: {blog_post: authenticated_resource, comment: Comment.new} }
      format.json { respond_with_200(authenticated_resource, :json) }
      format.json_api { respond_with_200(authenticated_resource, :json_api) }
      format.n3 { respond_with_200(authenticated_resource, :n3) }
      format.js { render locals: {blog_post: authenticated_resource} }
    end
  end

  private

  def update_respond_blocks_success(resource, format)
    format.html { update_respond_success_html(resource) }
    format.js { update_respond_success_js(resource) }
    format.json { respond_with_200(resource, :json) }
    format.json_api { respond_with_204(resource, :json_api) }
    format.n3 { respond_with_204(resource, :n3) }
  end

  def redirect_model_success(resource)
    return super unless action_name == 'create' && resource.persisted?
    url_for_blog_post(resource, only_path: true)
  end
end
