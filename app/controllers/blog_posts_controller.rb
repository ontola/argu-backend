# frozen_string_literal: true
class BlogPostsController < EdgeTreeController
  include BlogPostsHelper

  def show
    @comments = authenticated_resource.filtered_threads(show_trashed?, params[:page])
    respond_to do |format|
      format.html { render locals: {blog_post: authenticated_resource, comment: Comment.new} }
      format.json { render json: authenticated_resource }
      format.js   { render locals: {blog_post: authenticated_resource} }
    end
  end

  private

  def resource_tenant
    get_parent_resource.forum if current_resource_is_nested?
  end

  def update_respond_blocks_success(resource, format)
    format.html { redirect_to url_for(url_for_blog_post(resource)) }
    format.json { render json: resource, status: 200, location: resource }
    format.json_api { head :no_content }
  end

  def redirect_model_success(resource)
    return super unless action_name == 'create'
    url_for(url_for_blog_post(resource))
  end
end
