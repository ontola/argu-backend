# frozen_string_literal: true

class CommentsController < EdgeableController # rubocop:disable Metrics/ClassLength
  include UriTemplateHelper
  skip_before_action :check_if_registered, only: :index

  private

  def create_failure_html
    c = authenticated_resource
    url = "#{c.parent.iri}?#{{comment: {body: c.body, parent_id: c.in_reply_to_id}}.to_param}"
    redirect_to url, notice: c.errors.full_messages.first
  end

  def create_meta
    data = super
    if authenticated_resource.parent.enhanced_with?(Opinionable) && authenticated_resource.vote_id.present?
      voteable = authenticated_resource.parent
      action_delta(data, :remove, voteable.comment_collection, :create_opinion, include_parent: true)
      action_delta(data, :add, voteable, :update_opinion)
    end
    data
  end

  def create_service_parent
    parent = super
    parent = parent.parent if parent.is_a?(Comment)
    parent
  end

  def create_success_html
    respond_with_redirect(location: redirect_location)
  end

  def create_success_js
    return create_success if params[:modal].blank?
    flash.now[:notice] = active_response_success_message
    render 'alert'
  end

  def destroy_failure_js
    render
  end

  def index_success_html
    parent = parent_resource!
    if parent.is_a?(Comment)
      skip_verify_policy_scoped(true)
      redirect_to collection_iri(parent.parent, :comments)
    else
      @comment_edges = policy_scope(parent.filtered_threads(show_trashed?, params[:comments_page]))
      render locals: {comment: Comment.new}
    end
  end

  def index_success_js
    @comment_edges = policy_scope(parent_resource!.filtered_threads(show_trashed?, params[:comments_page]))
    render locals: {commentable: parent_resource!}
  end

  def new_html
    comment = params[:comment]
    render locals: {
      parent_id: comment.is_a?(Hash) ? comment[:parent_id] : nil,
      commentable: authenticated_resource.parent,
      comment: authenticated_resource
    }
  end

  def redirect_location
    case authenticated_resource.parent
    when BlogPost, ProArgument, ConArgument
      authenticated_resource.parent.iri(fragment: authenticated_resource.identifier)
    else
      expand_uri_template(
        'comments_collection_iri',
        parent_iri: split_iri_segments(authenticated_resource.parent.iri.path),
        with_hostname: true
      )
    end
  end

  def destroy_success_location
    authenticated_resource.parent.iri
  end

  def resource_new_params
    params = super
    params[:in_reply_to_id] = parent_resource.uuid if parent_resource.is_a?(Comment)
    params
  end

  def default_form_view_locals(_action)
    {
      comment: authenticated_resource,
      commentable: authenticated_resource.parent,
      parent_id: params[:comment].try(:[], :parent_id),
      resource: authenticated_resource,
      visible: true
    }
  end

  def show_success_html
    redirect_to redirect_location
  end

  def update_failure_html
    render 'edit',
           locals: {
             commentable: authenticated_resource.parent,
             comment: authenticated_resource,
             parent_id: nil
           }
  end

  def update_failure_js
    render 'failed',
           status: 400,
           locals: {
             comment: authenticated_resource,
             commentable: authenticated_resource.parent
           }
  end

  def update_success_html
    redirect_to authenticated_resource.iri,
                notice: t('comments.notices.updated')
  end

  def update_success_js
    render locals: {
      comment: authenticated_resource,
      commentable: authenticated_resource.parent
    }
  end
end
