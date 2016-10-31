# frozen_string_literal: true
class BlogPostsController < AuthorizedController
  include NestedResourceHelper, BlogPostsHelper

  def new
    respond_to do |format|
      format.html { render locals: {blog_post: authenticated_resource!} }
      format.json { render json: authenticated_resource! }
    end
  end

  def create
    create_service.on(:create_blog_post_successful) do |blog_post|
      respond_to do |format|
        format.html { redirect_to url_for(url_for_blog_post(blog_post)) }
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
    @comments = authenticated_resource.filtered_threads(show_trashed?, params[:page])
    respond_to do |format|
      format.html { render locals: {blog_post: authenticated_resource, comment: Comment.new} }
      format.json { render json: authenticated_resource }
      format.js   { render locals: {blog_post: authenticated_resource} }
    end
  end

  def edit
    if authenticated_resource!.argu_publication.try(:published_at).present?
      authenticated_resource!.argu_publication.schedule!
    else
      authenticated_resource!.argu_publication.draft!
      authenticated_resource!.argu_publication.published_at = DateTime.current
    end

    respond_to do |format|
      format.html { render locals: {blog_post: authenticated_resource!} }
      format.json { render json: authenticated_resource! }
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
        format.html { render :new, locals: {blog_post: blog_post} }
        format.json { render json: blog_post.errors, status: 422 }
      end
    end
    update_service.commit
  end

  # DELETE /blog_posts/1?destroy=true
  # DELETE /blog_posts/1.json?destroy=true
  def destroy
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

  def new_resource_from_params
    blog_post = super
    blog_post.build_happening(created_at: Time.current)
    blog_post.build_argu_publication(publish_type: :direct,
                                     published_at: DateTime.current)
    blog_post
  end

  def resource_new_params
    h = super.merge(blog_postable: get_parent_resource)
    h.delete(parent_resource_param)
    h
  end

  def resource_tenant
    get_parent_resource.forum if current_resource_is_nested?
  end
end
