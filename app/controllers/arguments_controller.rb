# frozen_string_literal: true

class ArgumentsController < EdgeTreeController
  skip_before_action :check_if_registered, only: :index

  private

  def authenticated_resource!
    return super unless params[:action] == 'index'
    parent_resource!
  end

  def deserialize_params_options
    {keys: {name: :title, text: :content}}
  end

  def include_show
    [comment_collection: inc_nested_collection]
  end

  def new_respond_blocks_success(resource, format)
    resource.assign_attributes(pro: %w[pro yes].include?(params[:pro] || params[:filter].try(:[], :option)))
    return super if params[:motion_id].present?
    format.html { render text: 'Bad request', status: 400 }
    format.json { respond_with_400(resource, :json) }
    format.json_api { respond_with_400(resource, :json_api) }
    format.nt { respond_with_400(resource, :nt) }
    format.ttl { respond_with_400(resource, :ttl) }
    format.jsonld { respond_with_400(resource, :jsonld) }
    format.rdf { respond_with_400(resource, :rdf) }
  end

  def prepare_view
    @comment_edges = authenticated_resource.filtered_threads(show_trashed?, params[:comments_page])
    @length = authenticated_resource.root_comments.length
    @vote = Vote.find_by(
      voteable_id: authenticated_resource.id,
      voteable_type: 'Argument',
      creator: current_profile
    )
  end

  def service_options(opts = {})
    super(opts.merge(auto_vote:
                       params.dig(:argument, :auto_vote) == 'true' &&
                         current_actor.actor == current_user.profile))
  end

  def show_respond_success_html(resource)
    prepare_view
    render locals: {
      argument: resource,
      comment: Edge.new(owner: Comment.new, parent: resource.edge).owner
    }
  end

  def show_respond_success_js(resource)
    prepare_view
    render locals: {
      argument: resource,
      comment: Edge.new(owner: Comment.new, parent: resource.edge).owner
    }
  end

  def redirect_model_success(resource)
    return super unless action_name == 'create' && resource.persisted?
    url_for([resource.parent_model, only_path: true])
  end
end
