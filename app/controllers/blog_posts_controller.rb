# frozen_string_literal: true

class BlogPostsController < EdgeTreeController
  include BlogPostsHelper

  def show
    @comments = authenticated_resource.filtered_threads(show_trashed?, params[:page])
    respond_to do |format|
      format.html { render locals: {blog_post: authenticated_resource, comment: Comment.new} }
      format.json { respond_with_200(authenticated_resource, :json) }
      format.json_api { respond_with_200(authenticated_resource, :json_api) }
      format.js { render locals: {blog_post: authenticated_resource} }
    end
  end

  private

  def update_respond_blocks_success(resource, format)
    format.html { update_respond_success_html(resource) }
    format.json { respond_with_200(resource, :json) }
    format.json_api { respond_with_204(resource, :json_api) }
  end

  def redirect_model_success(resource)
    return super unless action_name == 'create'
    url_for(url_for_blog_post(resource))
  end
end
