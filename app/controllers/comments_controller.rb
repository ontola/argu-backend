# frozen_string_literal: true

class CommentsController < EdgeTreeController
  skip_before_action :check_if_registered, only: :index

  def new
    comment = params[:comment]
    render locals: {
      parent_id: comment.is_a?(Hash) ? comment[:parent_id] : nil,
      resource: authenticated_resource.parent_model,
      comment: authenticated_resource
    }
  end

  def show
    respond_to do |format|
      format.html { redirect_to redirect_model_success(authenticated_resource) }
      format.json_api { respond_with_200(authenticated_resource, :json_api) }
    end
  end

  private

  def collect_banners; end

  def comment_body
    if params[:comment].is_a?(String)
      Bugsnag.notify('comment_body should always be a hash')
      raise StandardError('should always be a hash')
    end
    params[:comment].try(:[], :body)
  end

  def create_respond_failure_html(c)
    redirect_to polymorphic_url([c.parent_model],
                                comment: {
                                  body: c.body,
                                  parent_id: c.parent_id
                                }, anchor: c.id),
                notice: c.errors.full_messages.first
  end

  def create_respond_success_html(resource)
    respond_with_redirect_success(resource, :create)
  end

  def create_respond_success_js(resource)
    return super if params[:modal].blank?
    flash.now[:notice] = message_success(resource, :create)
    render 'alert'
  end

  def destroy_respond_failure_js
    render
  end

  def edit_respond_success_html(resource)
    render locals: {
      resource: resource.parent_model,
      comment: resource
    }
  end

  def edit_respond_success_js(resource)
    render locals: {
      resource: resource.parent_model,
      comment: resource,
      parent_id: nil,
      visible: true
    }
  end

  def index_respond_blocks_success(_, format)
    format.json_api do
      render json: index_response_association,
             include: include_index
    end
    format.html do
      @comments = parent_resource!.filtered_threads(show_trashed?, params[:page])
      render locals: {comment: Comment.new}
    end
  end

  def new_resource_from_params
    @resource ||= parent_resource!
                    .edge
                    .children
                    .new(owner: parent_resource!.comment_threads.new(resource_new_params))
                    .owner
  end

  def redirect_model_success(resource)
    if [Motion, Question].include?(resource.parent_model.class)
      polymorphic_url([resource.parent_model, :comments])
    else
      polymorphic_url([resource.parent_model], anchor: resource.identifier)
    end
  end
  alias redirect_model_failure redirect_model_success

  def resource_new_params
    super.merge(body: comment_body)
  end

  def query_payload(opts = {})
    query = opts.merge(comment: {body: comment_body})
    query[:comment] << {parent_id: params[:parent_id]} if params[:parent_id].present?
    query.to_query
  end

  def redirect_url
    return super unless params[:action] == 'create'
    redirect_url = URI.parse(url_for([:new, parent_resource!, :comment, only_path: true]))
    redirect_url.query = query_payload(confirm: true)
    redirect_url
  end

  def respond_with_form_js(resource)
    respond_js(
      'comments/new',
      parent_id: params[:comment][:parent_id],
      resource: resource.parent_model,
      comment: resource
    )
  end

  def update_respond_failure_html(resource)
    render 'edit',
           locals: {
             resource: resource.parent_model,
             comment: resource,
             parent_id: nil
           }
  end

  def update_respond_failure_js(resource)
    render 'failed',
           status: 400,
           locals: {
             comment: resource,
             commentable: resource.parent_model
           }
  end

  def update_respond_success_html(resource)
    redirect_to comment_url(resource),
                notice: t('comments.notices.updated')
  end

  def update_respond_success_js(resource)
    render locals: {
      comment: resource,
      commentable: resource.parent_model
    }
  end
end
