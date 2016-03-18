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

  # PUT /blog_posts/1/untrash
  # PUT /blog_posts/1/untrash.json
  def untrash
    blog_post = BlogPost.find params[:id]
    respond_to do |format|
      if blog_post.untrash
        format.html { redirect_to blog_post.blog_postable, notice: t('type_untrash_success', type: t('blog_posts.type')) }
        format.json { head :no_content }
      else
        format.html { render :form, notice: t('errors.general') }
        format.json { render json: blog_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blog_posts/1
  # DELETE /blog_posts/1.json
  def destroy
    blog_post = BlogPost.find params[:id]
    if blog_post.is_trashed?
      if params[:destroy].present? && params[:destroy] == 'true'
        authorize blog_post
        blog_post.destroy
        flash[:notice] = t('type_destroy_success',
                           type: t('blog_posts.type'))
      end
    else
      authorize blog_post, :trash?
      blog_post.trash
      flash[:notice] = t('type_trash_success',
                         type: t('blog_posts.type'))
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

  def resource_tenant
    get_parent_resource.forum
  end
end
