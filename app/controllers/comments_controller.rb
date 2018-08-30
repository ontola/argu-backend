# frozen_string_literal: true

class CommentsController < EdgeableController # rubocop:disable Metrics/ClassLength
  include UriTemplateHelper
  skip_before_action :check_if_registered, only: :index

  def new
    comment = params[:comment]
    render locals: {
      parent_id: comment.is_a?(Hash) ? comment[:parent_id] : nil,
      resource: authenticated_resource.parent,
      comment: authenticated_resource
    }
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

  def create_failure_html
    c = authenticated_resource
    url = "#{c.parent.iri_path}?#{{comment: {body: c.body, parent_id: c.in_reply_to_id}}.to_param}"
    redirect_to url, notice: c.errors.full_messages.first
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
    @comment_edges = policy_scope(parent_resource!.filtered_threads(show_trashed?, params[:comments_page]))
    render locals: {comment: Comment.new}
  end

  def index_success_js
    @comment_edges = policy_scope(parent_resource!.filtered_threads(show_trashed?, params[:comments_page]))
    render locals: {resource: parent_resource!}
  end

  def redirect_location
    case authenticated_resource.parent
    when BlogPost, ProArgument, ConArgument
      authenticated_resource.parent.iri_path(fragment: authenticated_resource.identifier)
    else
      expand_uri_template(
        'comments_collection_iri',
        parent_iri: authenticated_resource.parent.iri_path,
        only_path: true
      )
    end
  end

  def destroy_success_location
    authenticated_resource.parent.iri_path
  end

  def resource_new_params
    return super if afe_request?
    super.merge(body: comment_body)
  end

  def query_payload(opts = {})
    query = opts.merge(comment: {body: comment_body})
    query[:comment] << {parent_id: params[:parent_id]} if params[:parent_id].present?
    query.to_query
  end

  def after_login_location
    return super unless params[:action] == 'create'
    redirect_url = URI.parse(new_iri_path(parent_resource!, :comments))
    redirect_url.query = query_payload(confirm: true)
    redirect_url
  end

  def default_form_view_locals(_action)
    {
      comment: authenticated_resource,
      parent_id: params[:comment].try(:[], :parent_id),
      resource: authenticated_resource.parent,
      visible: true
    }
  end

  def show_includes
    [
      creator: :default_profile_photo,
      comment_collection: inc_shallow_collection
    ]
  end

  def show_success_html
    redirect_to redirect_location
  end

  def update_failure_html
    render 'edit',
           locals: {
             resource: authenticated_resource.parent,
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
    redirect_to authenticated_resource.iri_path,
                notice: t('comments.notices.updated')
  end

  def update_success_js
    render locals: {
      comment: authenticated_resource,
      commentable: authenticated_resource.parent
    }
  end
end
