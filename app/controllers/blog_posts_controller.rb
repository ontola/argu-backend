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

  def update
    update_service.on(:update_blog_post_successful) do |blog_post|
      respond_to do |format|
        format.html { redirect_to url_for(url_for_blog_post(blog_post)) }
        format.json { render json: blog_post, status: 200, location: blog_post }
      end
    end
    update_service.on(:update_blog_post_failed) do |blog_post|
      respond_to do |format|
        format.html { render :form, locals: {blog_post: blog_post} }
        format.json { render json: blog_post.errors, status: 422 }
      end
    end
    update_service.commit
  end

  private

  def resource_tenant
    get_parent_resource.forum if current_resource_is_nested?
  end

  def success_redirect_model(resource)
    return super unless action_name == 'create'
    url_for(url_for_blog_post(resource))
  end
end
