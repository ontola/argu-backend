# frozen_string_literal: true
class CommentsController < EdgeTreeController
  skip_before_action :check_if_registered, only: :index

  def new
    render locals: {
      parent_id: params[:comment].is_a?(Hash) ? params[:comment][:parent_id] : nil,
      resource: authenticated_resource.parent_model,
      comment: authenticated_resource
    }
  end

  def show
    respond_to do |format|
      format.html do
        redirect_to url_for([authenticated_resource.parent_model, anchor: authenticated_resource.identifier])
      end
      format.json_api { render json: authenticated_resource }
    end
  end

  def forum_for(url_options)
    comment = Comment.find_by(id: url_options[:id]) if url_options[:id].present?
    if comment.present?
      comment.parent_model(:forum)
    elsif url_options[:argument_id].present?
      Argument.find_by(id: url_options[:argument_id]).try(:forum)
    end
  end

  private

  def comment_body
    if params[:comment].is_a?(String)
      Bugsnag.notify('comment_body should always be a hash')
      raise StandardError('should always be a hash')
    end
    params[:comment].try(:[], :body)
  end

  def create_handler_failure(c)
    redirect_to polymorphic_url([c.parent_model],
                                comment: {
                                  body: c.body,
                                  parent_id: c.parent_id
                                }, anchor: c.id),
                notice: c.errors.full_messages.first
  end

  def create_handler_success(c)
    redirect_to polymorphic_url(c.parent_model, anchor: c.identifier),
                notice: t('type_create_success', type: t('comments.type'))
  end

  def destroy_respond_blocks_failure(resource, format)
    format.html do
      redirect_to polymorphic_url([resource.parent_model], anchor: resource.id),
                  notice: t('errors.general')
    end
    format.js # destroy_comment.js
  end

  # DELETE /arguments/1/comments/1?destroy=true
  def destroy_respond_blocks_success(resource, format)
    format.html { redirect_to polymorphic_url([resource.parent_model], anchor: resource.id) }
    format.js # destroy_comment.js
  end

  def edit_respond_blocks_success(resource, format)
    format.html do
      render locals: {
        resource: resource.parent_model,
        comment: resource
      }
    end
    format.js do
      render locals: {
        resource: resource.parent_model,
        comment: resource,
        parent_id: nil,
        visible: true
      }
    end
  end

  def new_resource_from_params
    @resource ||= get_parent_resource
                    .edge
                    .children
                    .new(owner: get_parent_resource.comment_threads.new(resource_new_params))
                    .owner
  end

  def resource_new_params
    super.merge(body: comment_body)
  end

  def query_payload(opts = {})
    query = opts.merge(comment: {body: comment_body})
    query[:comment] << {parent_id: params[:parent_id]} if params[:parent_id].present?
    query.to_query
  end

  def redirect_url
    if params[:action] == 'create'
      redirect_url = URI.parse(url_for([:new, get_parent_resource, :comment, only_path: true]))
      redirect_url.query = query_payload(confirm: true)
      redirect_url
    else
      super
    end
  end

  def resource_tenant
    return super if params[:forum_id].present?

    resource, id = request.path.split('/')[1, 2]
    # noinspection RubyCaseWithoutElseBlockInspection
    resource =
      case resource
      when 'a' then Argument
      when 'posts' then BlogPost
      end
    resource&.find(id)&.forum
  end

  def trash_respond_blocks_failure(resource, format)
    format.html do
      redirect_to polymorphic_url([resource.parent_model], anchor: resource.id),
                  notice: t('errors.general')
    end
    format.js # destroy_comment.js
  end

  def trash_respond_blocks_success(resource, format)
    format.html do
      redirect_to polymorphic_url([resource.parent_model], anchor: resource.id),
                  notice: t('type_trash_success', type: t('comments.type'))
    end
    format.js # destroy_comment.js
  end

  def untrash_respond_blocks_failure
    format.html do
      redirect_to polymorphic_url([resource.parent_model], anchor: resource.id),
                  notice: t('errors.general')
    end
    format.js # destroy_comment.js
  end

  def untrash_respond_blocks_success
    format.html do
      redirect_to polymorphic_url([resource.parent_model], anchor: resource.id),
                  notice: t('type_untrash_success', type: t('comments.type'))
    end
    format.js # destroy_comment.js
  end

  def update_respond_blocks_failure(resource, format)
    format.html do
      render 'edit',
             locals: {
               resource: resource.parent_model,
               comment: resource,
               parent_id: nil
             }
    end
    format.js do
      render 'failed',
             status: 400,
             locals: {
               comment: resource,
               commentable: resource.parent_model
             }
    end
    format.json do
      render json: resource.errors,
             status: :unprocessable_entity
    end
  end

  def update_respond_blocks_success(resource, format)
    format.html do
      redirect_to comment_url(resource),
                  notice: t('comments.notices.updated')
    end
    format.js do
      render locals: {
        comment: resource,
        commentable: resource.parent_model
      }
    end
    format.json { head :no_content }
  end
end
