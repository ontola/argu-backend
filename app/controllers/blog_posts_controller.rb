# frozen_string_literal: true

class BlogPostsController < EdgeTreeController
  include BlogPostsHelper
  skip_before_action :check_if_registered, only: :index

  def show
    @comment_edges = authenticated_resource.filtered_threads(show_trashed?, params[:comments_page])
    show_handler_success(authenticated_resource)
  end

  private

  def update_respond_blocks_success(resource, format)
    format.html { update_respond_success_html(resource) }
    format.js { update_respond_success_js(resource) }
    format.json { respond_with_200(resource, :json) }
    format.json_api { respond_with_204(resource, :json_api) }
    format.nt { respond_with_204(resource, :nt) }
    format.ttl { respond_with_204(resource, :ttl) }
    format.jsonld { respond_with_204(resource, :jsonld) }
    format.rdf { respond_with_204(resource, :rdf) }
  end

  def redirect_model_success(resource)
    return super unless action_name == 'create' && resource.persisted?
    url_for_blog_post(resource, only_path: true)
  end

  def show_respond_success_html(resource)
    render locals: {blog_post: resource, comment: Comment.new}
  end

  def show_respond_success_js(resource)
    render locals: {blog_post: resource}
  end
end
