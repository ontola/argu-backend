class BlogPostsController < AuthorizedController
  include NestedResourceHelper

  def new
    respond_to do |format|
      format.html { render locals: {blog_post: authenticated_resource!} }
      format.json { render json: authenticated_resource! }
    end
  end

  def create
    create_service.subscribe(ActivityListener.new(creator: current_profile,
                                                  publisher: current_user))
    create_service.on(:create_blog_post_successful) do |blog_post|
      respond_to do |format|
        format.html { redirect_to blog_post }
        format.json { render json: blog_post, status: 201, location: blog_post }
      end
    end
    create_service.on(:create_blog_post_failed) do |blog_post|
      respond_to do |format|
        format.html { render :new, locals: {blog_post: blog_post} }
        format.json { render json: blog_post.errors, status: 422 }
      end
    end
    create_service.commit
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
    update_service.subscribe(ActivityListener.new(creator: current_profile,
                                                  publisher: current_user))
    update_service.on(:update_blog_post_successful) do |blog_post|
      respond_to do |format|
        format.html { redirect_to blog_post }
        format.json { render json: blog_post, status: 200, location: blog_post }
      end
    end
    update_service.on(:update_blog_post_failed) do |blog_post|
      respond_to do |format|
        format.html { render :new, locals: {blog_post: blog_post} }
        format.json { render json: blog_post.errors, status: 422 }
      end
    end
    update_service.commit
  end

  # DELETE /blog_posts/1?destroy=true
  # DELETE /blog_posts/1.json?destroy=true
  def destroy
    destroy_service.subscribe(ActivityListener.new(creator: current_profile,
                                                   publisher: current_user))
    destroy_service.on(:destroy_blog_post_successful) do |blog_post|
      respond_to do |format|
        format.html do
          redirect_to blog_post.blog_postable,
                      notice: t('type_destroy_success', type: t('blog_posts.type'))
        end
        format.json { head :no_content }
      end
    end
    destroy_service.on(:destroy_blog_post_failed) do |blog_post|
      respond_to do |format|
        format.html { redirect_to blog_post, notice: t('errors.general') }
        format.json { render json: blog_post.errors, status: :unprocessable_entity }
      end
    end
    destroy_service.commit
  end

  # DELETE /blog_posts/1
  # DELETE /blog_posts/1.json
  def trash
    trash_service.subscribe(ActivityListener.new(creator: current_profile,
                                                 publisher: current_user))
    trash_service.on(:trash_blog_post_successful) do |blog_post|
      respond_to do |format|
        format.html do
          redirect_to blog_post.blog_postable,
                      notice: t('type_trash_success', type: t('blog_posts.type'))
        end
        format.json { head :no_content }
      end
    end
    trash_service.on(:trash_blog_post_failed) do |blog_post|
      respond_to do |format|
        format.html { redirect_to blog_post, notice: t('errors.general') }
        format.json { render json: blog_post.errors, status: :unprocessable_entity }
      end
    end
    trash_service.commit
  end

  # PUT /blog_posts/1/untrash
  # PUT /blog_posts/1/untrash.json
  def untrash
    untrash_service.subscribe(ActivityListener.new(creator: current_profile,
                                                   publisher: current_user))
    untrash_service.on(:untrash_blog_post_successful) do |blog_post|
      respond_to do |format|
        format.html { redirect_to blog_post, notice: t('type_untrash_success', type: t('blog_posts.type')) }
        format.json { head :no_content }
      end
    end
    untrash_service.on(:untrash_blog_post_failed) do |blog_post|
      respond_to do |format|
        format.html { redirect_to blog_post, notice: t('errors.general') }
        format.json { render json: blog_post.errors, status: :unprocessable_entity }
      end
    end
    untrash_service.commit
  end

  private

  def create_service
    @create_service ||= CreateBlogPost.new(
      BlogPost.new,
      permit_params.merge(resource_new_params.merge(publisher: current_user,
                                                    creator: current_profile)))
  end

  def destroy_service
    @destroy_service ||= DestroyBlogPost.new(resource_by_id)
  end

  def permit_params
    params
      .require(:blog_post)
      .permit(*policy(@blog_post || resource_by_id || new_resource_from_params || BlogPost).permitted_attributes)
  end

  def resource_new_params
    h = super.merge(
      publish_type: :direct,
      publish_at: Time.current,
      blog_postable: get_parent_resource)
    h.delete(parent_resource_param)
    h
  end

  def resource_tenant
    get_parent_resource.forum
  end

  def trash_service
    @trash_service ||= TrashBlogPost.new(resource_by_id)
  end

  def untrash_service
    @untrash_service ||= UntrashBlogPost.new(resource_by_id)
  end

  def update_service
    @update_service ||= UpdateBlogPost.new(
      resource_by_id,
      permit_params)
  end
end
