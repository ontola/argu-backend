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
    [operation: :target, comment_collection: inc_nested_collection]
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
    @length = authenticated_resource.root_comments.length
    @vote = Vote.find_by(
      voteable_id: authenticated_resource.id,
      voteable_type: 'Argument',
      creator: current_profile
    )
  end

  def create_register_failure
    action_service
      .on(:create_pro_argument_failed, :create_con_argument_failed) { |r| create_handler_failure(r) }
  end

  def create_register_success
    action_service
      .on(:create_pro_argument_successful, :create_con_argument_successful) { |r| create_handler_success(r) }
  end

  def redirect_model_success(resource)
    return super unless action_name == 'create' && resource.persisted?
    resource.parent_model.iri(only_path: true).to_s
  end

  def resource_by_id
    return @_resource_by_id if instance_variable_defined?('@_resource_by_id')
    @_resource_by_id = Argument.find_by(id: resource_id)
    return @_resource_by_id if @_resource_by_id.nil? || @_resource_by_id.class == controller_class
    redirect_to request.original_url.gsub(%r{\/(con|pro|a)\/}, "/#{@_resource_by_id.type.remove('Argument').downcase}/")
    nil
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

  def update_register_failure
    action_service
      .on(:update_pro_argument_failed, :update_con_argument_failed) { |r| update_handler_failure(r) }
  end

  def update_register_success
    action_service
      .on(:update_pro_argument_successful, :update_con_argument_successful) { |r| update_handler_success(r) }
  end
end
