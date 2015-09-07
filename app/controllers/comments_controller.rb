class CommentsController < ApplicationController
  skip_after_action :verify_policy_scoped, :only => :index

  # Note: Used to redirect to confirm in the 'r' system
  def index
    if params[:comment].present?
      redirect_to({controller: 'comments', action: :new, commentable_param => params[commentable_param], comment: params[:comment]})
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def new
    @commentable = commentable_class.find params[commentable_param]
    @comment = Comment.build_from(@commentable, current_profile.id, params[:comment])
    authorize @comment, :create?

    render locals: {
               resource: @commentable,
               comment: @comment
           }
  end

  def show
    @comment = Comment.find params[:id]
    authorize @comment, :show?

    respond_to do |format|
      format.html { redirect_to url_for([@comment.commentable, anchor: @comment.identifier]) }
    end
  end

  def edit
    @commentable = commentable_class.find params[commentable_param]
    @comment = @commentable.comment_threads.find params[:id]
    current_context @comment
    authorize @comment, :edit?

    respond_to do |format|
      format.html { render locals: {
                               resource: @commentable,
                               comment: @comment
                           }
      }
      format.js { render locals: {
                               resource: @commentable,
                               comment: @comment,
                               parent_id: nil,
                               visible: true
                           }
      }
    end
  end

  # POST /resource/1/comments
  def create
    resource = get_commentable
    comment_body = params[:comment].is_a?(String) ? params[:comment] : params[:comment][:body]
    if current_profile.blank?
      authorize resource, :show?
      render_register_modal(nil, [:comment, comment_body], [:parent_id, params[:parent_id]])
    else
      @comment = Comment.build_from(resource, current_profile.id, comment_body)
      authorize @comment
      parent = Comment.find_by_id params[:parent_id] unless params[:parent_id].blank?
      #unless params[:parent_id].blank?
      #  #@TODO Just let them go nuts for now, infinite parenting
      #  @comment.move_to_child_of Comment.find_by_id params[:parent_id]
      #end

      respond_to do |format|
        if !current_profile.member_of? resource.forum
          redirect_url = URI.parse(request.fullpath)
          redirect_url.query= [[:comment, CGI::escape(comment_body)], [:parent_id, params[:parent_id]]].map { |a| a.join('=') }.join('&')
          format.js { render partial: 'forums/join', layout: false, locals: { forum: resource.forum, r: redirect_url.to_s } }
          format.html { render template: 'forums/join', locals: { forum: resource.forum, r: redirect_url.to_s } }
        elsif @comment.save
          @comment.move_to_child_of(parent) if parent.present? # Apparently, move_possible? doesn't exists anymore
          create_activity @comment, action: :create, recipient: resource, parameters: { parent: parent.try(:id) }, owner: current_profile, forum_id: resource.forum.id
          format.js { render }
          format.html { redirect_to polymorphic_url([resource], anchor: @comment.id), notice: t('type_create_success', type: t('comments.type')) }
        else
          #@comment.destroy unless @comment.new_record? # TODO: this shit deletes all comments, so thats not really a great thing..
          format.html { redirect_to polymorphic_url([resource], anchor: @comment.id), notice: '_niet gelukt_' }
          format.js { render 'failed', status: 400 }
        end
      end
    end
  end

  def update
    @commentable = commentable_class.find params[commentable_param]
    authorize @commentable, :show?
    @comment = @commentable.comment_threads.find params[:id]
    authorize @comment, :edit?

    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: t('comments.notices.updated') }
        format.js { render }
        format.json { head :no_content }
      else
        format.html { render 'edit',
                             locals: {
                                 resource: @commentable,
                                 comment: @comment,
                                 parent_id: nil
                             }}
        format.js { render 'failed', status: 400 }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arguments/1/comments/1
  def destroy
    @comment = Comment.find_by_id params[:id]
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
  def comment_params
    params.require(:comment).permit(*policy(@comment || Comment).permitted_attributes)
  end

  def get_commentable
    resource, id = request.path.split('/')[1,2]
    # noinspection RubyCaseWithoutElseBlockInspection
    resource = case resource
      when 'a' then Argument
    end
    resource.find(id)
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

end
