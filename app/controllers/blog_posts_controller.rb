class BlogPostsController < AuthorizedController
  include NestedResourceHelper

  def new
    respond_to do |format|
      format.html { render locals: {blog_post: authenticated_resource!} }
      format.json { render json: authenticated_resource! }
    end
  end

  def create
    @cbp = CreateBlogPost.new(
      current_profile,
      permit_params.merge(resource_new_params))

    authorize @cbp.resource, :create?
    @cbp.subscribe(ActivityListener.new)

    @cbp.on(:create_blog_post_successful) do |blog_post|
      respond_to do |format|
        format.html { redirect_to blog_post }
        format.json { render json: blog_post, status: 201, location: blog_post }
      end
    end
    @cbp.on(:create_blog_post_failed) do |blog_post|
      respond_to do |format|
        format.html { render :new, locals: {blog_post: blog_post} }
        format.json { render json: blog_post.errors, status: 422 }
      end
    end
    @cbp.commit
  end

  def show
    respond_to do |format|
      format.html { render locals: {blog_post: @resource} }
      format.json { render json: @resource }
    end
  end

  def edit
    respond_to do |format|
      format.html { render locals: {blog_post: authenticated_resource!} }
      format.json { render json: authenticated_resource! }
    end
  end

  def update
    @ubp = UpdateBlogPost.new(
      authenticated_resource!,
      permit_params)

    authorize @ubp.resource, :update?

    @ubp.on(:update_blog_post_successful) do |blog_post|
      respond_to do |format|
        format.html { redirect_to blog_post }
        format.json { render json: blog_post, status: 200, location: blog_post }
      end
    end
    @ubp.on(:update_blog_post_failed) do |blog_post|
      respond_to do |format|
        format.html { render :new, locals: {blog_post: blog_post} }
        format.json { render json: blog_post.errors, status: 422 }
      end
    end
    @ubp.commit
  end

  def destroy
    blog_post = BlogPost.find params[:id]
    if params[:destroy].to_s == 'true'
      authorize blog_post
      blog_post.destroy
    else
      authorize blog_post, :trash?
      blog_post.trash
    end

    respond_to do |format|
      format.html { redirect_to blog_post.blog_postable }
      format.json { head :no_content }
    end
  end

  private

  def resource_new_params
    h = super.merge({
      published_at: Time.current,
      blog_postable: get_parent_resource
    })
    h.delete(parent_resource_param)
    h
  end

  def permit_params
    params.require(:blog_post).permit(*policy(authenticated_resource || @blog_post || BlogPost).permitted_attributes)
  end

  def tenant_by_param
    get_parent_resource.forum
  end
end
