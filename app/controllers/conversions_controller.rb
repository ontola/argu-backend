# frozen_string_literal: true

class ConversionsController < ServiceController
  include ConvertibleHelper
  before_action :verify_convertible_edge

  private

  def authenticated_resource!
    @resource ||=
      case action_name
      when 'create'
        create_service.resource
      when 'new'
        new_resource_from_params
      end
  end

  def authorize_action
    authorize parent_resource!.owner, :convert?
    authorize authenticated_resource, :new?
  end

  def collect_banners; end

  def create_handler_success(resource)
    respond_to do |format|
      create_respond_blocks_success(
        resource.edge.owner,
        format
      )
    end
  end

  def create_service_parent
    Conversion.new(edge: parent_resource!)
  end

  def current_forum
    @current_forum ||= resource_by_id&.parent_model(:forum)
  end

  def new_respond_success_js(resource)
    render :form, locals: {conversion: resource}
  end

  def resource_by_id; end

  def redirect_model_success(resource)
    resource.owner.iri(only_path: true).to_s
  end

  def resource_new_params
    {
      edge: parent_resource!,
      klass: convertible_class_names(parent_resource!)&.first
    }
  end

  def service_options(options = {})
    {
      creator: current_actor.actor,
      publisher: current_user
    }.merge(options)
  end

  def verify_convertible_edge
    return if parent_resource!.is_convertible?
    respond_to do |format|
      format.html { render 'status/422', status: 422 }
      format.json do
        render status: 422,
               json: {
                 notifications: [
                   {
                     type: :error,
                     message: "#{parent_resource!.owner} is not convertible"
                   }
                 ]
               }
      end
    end
  end
end
