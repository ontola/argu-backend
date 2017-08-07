# frozen_string_literal: true
class ConversionsController < ServiceController
  include ConvertibleHelper
  helper_method :collect_banners

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
    authorize convertible_edge!.owner, :convert?
    authorize authenticated_resource, :new?
  end

  def collect_banners; end

  def convertible_edge
    @convertible_edge ||= Edge.find_by(id: params[:edge_id])
  end

  def convertible_edge!
    convertible_edge || raise(ActiveRecord::RecordNotFound)
  end

  def create_handler_success(resource)
    respond_to do |format|
      create_respond_blocks_success(
        resource.edge.owner,
        format
      )
    end
  end

  def create_service_parent
    Conversion.new(edge: convertible_edge!)
  end

  def current_forum
    @current_forum ||= convertible_edge&.parent_model(:forum)
  end

  def parent_edge
    convertible_edge&.parent
  end

  def parent_resource
    parent_edge&.owner
  end

  def resource_by_id; end

  def resource_new_params
    {
      edge: convertible_edge!,
      klass: convertible_class_names(convertible_edge!.owner)&.first
    }
  end

  def service_options(options = {})
    {
      creator: current_actor.actor,
      publisher: current_user
    }.merge(options)
  end

  def verify_convertible_edge
    return if convertible_edge!.owner.is_convertible?
    respond_to do |format|
      format.html { render 'status/422', status: 422 }
      format.json do
        render status: 422,
               json: {
                 notifications: [
                   {
                     type: :error,
                     message: "#{convertible_edge!.owner} is not convertible"
                   }
                 ]
               }
      end
    end
  end
end
