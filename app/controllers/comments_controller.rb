class CommentsController < ApplicationController
  before_action :check_if_registered, only: [:create]
  before_action :check_if_member, only: [:create]

  def new
    @commentable = commentable_class.find params[commentable_param]
    set_forum(@commentable)
    @comment = @commentable.comment_threads.new(comment_params_relaxed)
    authorize @comment, :create?

    render locals: {
               parent_id: params[:comment].is_a?(Hash) ? params[:comment][:parent_id] : nil,
               resource: @commentable,
               comment: @comment
           }
  end

  def show
    @comment = Comment.find params[:id]
    set_forum(@comment)
    authorize @comment, :show?

    respond_to do |format|
      format.html { redirect_to url_for([@comment.commentable, anchor: @comment.identifier]) }
    end
  end

  def edit
    @commentable = commentable_class.find params[commentable_param]
    @comment = @commentable.comment_threads.find params[:id]
    set_forum(@comment)
    current_context @comment
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
    resource = get_commentable
    set_forum(resource)
    @cc = CreateComment.new current_profile,
                           {
                               commentable: resource,
                               publisher: current_user
                           }.merge(comment_params)
    authorize @cc.resource, :create?
    @cc.subscribe(ActivityListener.new)
    @cc.subscribe(MailerListener.new)
    @cc.on(:create_comment_successful) do |c|
      redirect_to polymorphic_url([resource], anchor: c.id),
                  notice: t('type_create_success', type: t('comments.type'))
    end
    @cc.on(:create_comment_failed) do |c|
      redirect_to polymorphic_url([resource], anchor: c.id),
                  notice: '_niet gelukt_'
    end
    @cc.commit
  end

  def update
    @commentable = commentable_class.find params[commentable_param]
    @comment = @commentable.comment_threads.find params[:id]
    set_forum(@comment)
    authorize @comment, :edit?

    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment,
                                  notice: t('comments.notices.updated') }
        format.js { render }
        format.json { head :no_content }
      else
        format.html { render 'edit',
                             locals: {
                                 resource: @commentable,
                                 comment: @comment,
                                 parent_id: nil
                             }}
        format.js { render 'failed',
                           status: 400 }
        format.json { render json: @comment.errors,
                             status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arguments/1/comments/1
  def destroy
    @comment = Comment.find_by_id params[:id]
    set_forum(@comment)
    resource = @comment.commentable
    if params[:wipe] == 'true'
      authorize @comment
      @comment.wipe
    else
      authorize @comment, :trash?
      @comment.trash
    end
    respond_to do |format|
      format.html { redirect_to polymorphic_url([resource], anchor: @comment.id) }
      format.js # destroy_comment.js
    end
  end

private
  def check_if_member
    resource = get_commentable
    if current_profile.present? && !current_profile.member_of?(resource.forum)
      raise Argu::NotAMemberError.new(forum: resource.forum, r: redirect_url)
    end
  end

  def check_if_registered
    if current_profile.blank?
      resource = get_commentable
      authorize resource, :show?
      raise Argu::NotAUserError.new(resource.forum, redirect_url)
    end
  end

  def comment_body
    params[:comment].is_a?(String) ? params[:comment] : params[:comment][:body]
  end

  def comment_params
    params.require(:comment).permit(*policy(@comment || Comment).permitted_attributes)
  end

  def comment_params_relaxed
    params.permit(:comment).permit(*policy(@comment || Comment).permitted_attributes)
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

  def get_commentable
    resource, id = request.path.split('/')[1,2]
    # noinspection RubyCaseWithoutElseBlockInspection
    resource = case resource
      when 'a' then Argument
    end
    resource.find(id)
  end

  def query_payload(opts = {})
    query = opts.merge({comment: {body: comment_body}})
    query[:comment] << {parent_id: params[:parent_id]} if params[:parent_id].present?
    query.to_query
  end

  def redirect_url
    redirect_url = URI.parse(new_argument_comment_path(argument_id: params[:argument_id]))
    redirect_url.query = query_payload(confirm: true)
    redirect_url
  end

  def set_forum(item)
    @forum = item.forum
  end

end
