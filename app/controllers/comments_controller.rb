class CommentsController < AuthorizedController
  include NestedResourceHelper

  def new
    @commentable = commentable_class.find params[commentable_param]
    @comment = @commentable.comment_threads.new(new_comment_params.merge(resource_new_params))
    authorize @comment, :create?

    render locals: {
               parent_id: params[:comment].is_a?(Hash) ? params[:comment][:parent_id] : nil,
               resource: @commentable,
               comment: @comment
           }
  end

  def show
    respond_to do |format|
      format.html { redirect_to url_for([@comment.commentable, anchor: @comment.identifier]) }
    end
  end

  def edit
    @commentable = commentable_class.find params[commentable_param]
    @comment = @commentable.comment_threads.find params[:id]
    authorize @comment, :edit?

    respond_to do |format|
      format.html do
        render locals: {
                   resource: @commentable,
                   comment: @comment
               }
      end
      format.js do
        render locals: {
                   resource: @commentable,
                   comment: @comment,
                   parent_id: nil,
                   visible: true
               }
      end
    end
  end

  # POST /resource/1/comments
  def create
    create_service.subscribe(ActivityListener.new(creator: current_profile,
                                                  publisher: current_user))
    create_service.on(:create_comment_successful) do |c|
      redirect_to polymorphic_url(c.commentable, anchor: c.identifier),
                  notice: t('type_create_success', type: t('comments.type'))
    end
    create_service.on(:create_comment_failed) do |c|
      redirect_to polymorphic_url([c.commentable],
                                  comment: {
                                    body: c.body,
                                    parent_id: c.parent_id
                                  }, anchor: c.id),
                  notice: c.errors.full_messages.first
    end
    create_service.commit
  end

  def update
    update_service.subscribe(ActivityListener.new(creator: current_profile,
                                                  publisher: current_user))
    update_service.on(:update_comment_successful) do |comment|
      respond_to do |format|
        format.html do
          redirect_to comment_url(comment),
                      notice: t('comments.notices.updated')
        end
        format.js { render }
        format.json { head :no_content }
      end
    end
    update_service.on(:update_comment_failed) do |comment|
      respond_to do |format|
        format.html do
          render 'edit',
                 locals: {
                   resource: comment.commentable,
                   comment: comment,
                   parent_id: nil
                 }
        end
        format.js do
          render 'failed',
                 status: 400
        end
        format.json do
          render json: comment.errors,
                 status: :unprocessable_entity
        end
      end
    end
    update_service.commit
  end

  # DELETE /arguments/1/comments/1?destroy=true
  def destroy
    destroy_service.subscribe(ActivityListener.new(creator: current_profile,
                                                   publisher: current_user))
    destroy_service.on(:destroy_comment_successful) do |comment|
      respond_to do |format|
        format.html { redirect_to polymorphic_url([comment.commentable], anchor: comment.id) }
        format.js # destroy_comment.js
      end
    end
    destroy_service.on(:destroy_comment_failed) do |comment|
      respond_to do |format|
        format.html do
          redirect_to polymorphic_url([comment.commentable], anchor: comment.id),
                      notice: t('errors.general')
        end
        format.js # destroy_comment.js
      end
    end
    destroy_service.commit
  end

  # DELETE /arguments/1/comments/1
  def trash
    trash_service.subscribe(ActivityListener.new(creator: current_profile,
                                                 publisher: current_user))
    trash_service.on(:trash_comment_successful) do |comment|
      respond_to do |format|
        format.html do
          redirect_to polymorphic_url([comment.commentable], anchor: comment.id),
                      notice: t('type_trash_success', type: t('comments.type'))
        end
        format.js # destroy_comment.js
      end
    end
    trash_service.on(:trash_comment_failed) do |comment|
      respond_to do |format|
        format.html do
          redirect_to polymorphic_url([comment.commentable], anchor: comment.id),
                      notice: t('errors.general')
        end
        format.js # destroy_comment.js
      end
    end
    trash_service.commit
  end

  # PUT /arguments/1/comments/1/untrash
  # PUT /arguments/1/comments/1/untrash.json
  def untrash
    untrash_service.subscribe(ActivityListener.new(creator: current_profile,
                                                   publisher: current_user))
    untrash_service.on(:untrash_comment_successful) do |comment|
      respond_to do |format|
        format.html do
          redirect_to polymorphic_url([comment.commentable], anchor: comment.id),
                      notice: t('type_untrash_success', type: t('comments.type'))
        end
        format.js # destroy_comment.js
      end
    end
    untrash_service.on(:untrash_comment_failed) do |comment|
      respond_to do |format|
        format.html do
          redirect_to polymorphic_url([comment.commentable], anchor: comment.id),
                      notice: t('errors.general')
        end
        format.js # destroy_comment.js
      end
    end
    untrash_service.commit
  end

  def forum_for(url_options)
    comment = Comment.find_by(id: url_options[:id]) if url_options[:id].present?
    if comment.present?
      comment.commentable.try(:forum)
    elsif url_options[:argument_id].present?
      Argument.find_by(id: url_options[:argument_id]).try(:forum)
    end
  end

  private

  def authorize_show
    @comment = Comment.find params[:id]
    authorize @comment, :show?
  end

  def comment_body
    if Rails.env.development?
      raise StandardError('should always be a hash') if params[:comment].is_a?(String)
    end
    params[:comment].is_a?(String) ? params[:comment] : params[:comment][:body]
  end

  def permit_params
    params.require(:comment).permit(*policy(@comment || Comment).permitted_attributes)
  end

  def commentable_param
    request.path_parameters.keys.find { |k| /_id/ =~ k }
  end

  def commentable_type
    commentable_param[0..-4]
  end

  # Note: Safe to constantize since `path_parameters` uses the routes for naming.
  def commentable_class
    commentable_type.capitalize.constantize
  end

  def create_service
    @create_service ||= CreateComment.new(
      Comment.new,
      resource_new_params.merge(permit_params),
      service_options)
  end

  def destroy_service
    @destroy_service ||= DestroyComment.new(resource_by_id)
  end

  def new_comment_params
    params[:comment].present? ? permit_params : {}
  end

  def resource_new_params
    h = super.merge(
      commentable: get_parent_resource
    )
    h.delete(parent_resource_param)
    h
  end

  def query_payload(opts = {})
    query = opts.merge(comment: {body: comment_body})
    query[:comment] << {parent_id: params[:parent_id]} if params[:parent_id].present?
    query.to_query
  end

  def redirect_url
    if params[:action] == 'create'
      redirect_url = URI.parse(new_argument_comment_path(argument_id: params[:argument_id]))
      redirect_url.query = query_payload(confirm: true)
      redirect_url
    else
      super
    end
  end

  def resource_tenant
    return super if params[:forum_id].present?

    resource, id = request.path.split('/')[1,2]
    # noinspection RubyCaseWithoutElseBlockInspection
    resource =
      case resource
      when 'a' then Argument
      end
    resource.find(id).forum
  end

  def trash_service
    @trash_service ||= TrashComment.new(resource_by_id)
  end

  def untrash_service
    @untrash_service ||= UntrashComment.new(resource_by_id)
  end

  def update_service
    @update_service ||= UpdateComment.new(
      resource_by_id,
      permit_params,
      service_options)
  end
end
