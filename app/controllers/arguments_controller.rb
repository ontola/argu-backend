# frozen_string_literal: true

class ArgumentsController < EdgeableController
  skip_before_action :check_if_registered, only: :index

  private

  def argument_type
    params[:argument][:pro].to_s == 'true' ? :pro : :con
  end

  def authenticated_resource!
    return super unless params[:action] == 'index'
    parent_resource!
  end

  def deserialize_params_options
    {keys: {name: :title, text: :content}}
  end

  def include_show
    [operation: inc_action_form, comment_collection: inc_nested_collection]
  end

  def index_collection_association
    "#{argument_type}_argument_collection"
  end

  def new_respond_blocks_success(resource, format)
    resource.pro = %w[pro yes].include?(params[:pro] || params[:filter].try(:[], :option))
    return super if params[:motion_id].present?
    format.html { render text: 'Bad request', status: 400 }
    format.json { respond_with_400(resource, :json) }
    format.json_api { respond_with_400(resource, :json_api) }
    RDF_CONTENT_TYPES.each do |type|
      format.send(type) { respond_with_400(resource, type) }
    end
  end

  def prepare_view
    @comment_edges = authenticated_resource.filtered_threads(show_trashed?, params[:comments_page])
    @vote = Vote.find_by(
      parent_id: authenticated_resource.id,
      creator: current_profile
    )
  end

  def signals_failure
    [:"#{action_name}_pro_argument_failed", :"#{action_name}_con_argument_failed"]
  end

  def signals_success
    [:"#{action_name}_pro_argument_successful", :"#{action_name}_con_argument_successful"]
  end

  def redirect_model_success(resource)
    return super unless action_name == 'create' && resource.persisted?
    resource.parent.iri(only_path: true).to_s
  end

  def service_options(opts = {})
    super(opts.merge(auto_vote:
                       params.dig(model_name, :auto_vote) == 'true' &&
                         current_actor.actor == current_user.profile))
  end

  def show_respond_success_html(resource)
    prepare_view
    render locals: {
      argument: resource,
      comment: Comment.new(parent: resource)
    }
  end

  def show_respond_success_js(resource)
    prepare_view
    render locals: {
      argument: resource,
      comment: Comment.new(parent: resource)
    }
  end
end
