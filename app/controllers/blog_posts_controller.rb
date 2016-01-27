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
      permit_params.merge({
                            published_at: Time.current,
                            forum: authenticated_context,
                            publisher: current_user,
                            blog_postable: get_parent_resource
                          }))

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
      format.js   { render locals: {blog_post: @resource} }
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
    super.merge({
      blog_postable: get_parent_resource
    })
  end

  def permit_params
    params.require(:blog_post).permit(*policy(authenticated_resource || @blog_post || BlogPost).permitted_attributes)
  end

  def tenant_by_param
    get_parent_resource.forum
  end
end
