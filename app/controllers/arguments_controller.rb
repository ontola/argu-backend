# frozen_string_literal: true
class ArgumentsController < EdgeTreeController
  skip_before_action :check_if_registered, only: :index

  # GET /arguments/1
  # GET /arguments/1.json
  def show
    @comments = authenticated_resource.filtered_threads(show_trashed?, params[:page])
    @length = authenticated_resource.root_comments.length
    @vote = Vote.find_by(
      voteable_id: authenticated_resource.id,
      voteable_type: 'Argument',
      creator: current_profile
    )

    respond_to do |format|
      format.html do
        render locals: {
          argument: authenticated_resource,
          comment: Edge.new(owner: Comment.new, parent: authenticated_edge).owner
        }
      end
      format.widget do
        render authenticated_resource,
               locals: {argument: authenticated_resource}
      end
      format.json { respond_with_200(authenticated_resource, :json) }
      format.json_api do
        render json: authenticated_resource,
               include: [
                 comment_collection: INC_NESTED_COLLECTION
               ]
      end
    end
  end

  private

  def authenticated_resource!
    return super unless params[:action] == 'index'
    parent_resource!
  end

  def deserialize_params_options
    {keys: {name: :title, text: :content}}
  end

  def new_respond_blocks_success(resource, format)
    resource.assign_attributes(pro: %w(pro yes).include?(params[:pro] || params[:filter].try(:[], :option)))
    return super if params[:motion_id].present?
    format.html { render text: 'Bad request', status: 400 }
    format.json { respond_with_400(resource, :json) }
    format.json_api { respond_with_400(resource, :json_api) }
  end

  def service_options(opts = {})
    super(opts.merge(auto_vote:
                       params.dig(:argument, :auto_vote) == 'true' &&
                         current_actor.actor == current_user.profile))
  end

  def redirect_model_success(resource)
    return super unless action_name == 'create'
    resource.parent_model
  end
end
