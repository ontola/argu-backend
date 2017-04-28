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
    authorize convertible_edge.owner, :convert?
    authorize authenticated_resource, :new?
  end

  def collect_banners; end

  def convertible_edge
    @convertible_edge ||= Edge.find(params[:edge_id])
  end

  def create_handler_success(resource)
    respond_to do |format|
      create_respond_blocks_success(
        resource.edge.owner,
        format
      )
    end
  end

  def create_service
    @create_service ||= CreateConversion.new(
      Conversion.new(edge: convertible_edge),
      attributes: permit_params,
      options: service_options
    )
  end

  def permit_params
    params
      .require(:conversion)
      .permit(*policy(new_resource_from_params).permitted_attributes)
  end

  def new_resource_from_params
    Conversion.new(
      edge: convertible_edge,
      klass: convertible_class_names(convertible_edge.owner).first
    )
  end

  def new_respond_blocks_success(resource, format)
    format.html { render :form, locals: {conversion: resource} }
  end

  def service_options(options = {})
    {
      creator: current_profile,
      publisher: current_user
    }.merge(options)
  end

  def verify_convertible_edge
    return if convertible_edge.owner.is_convertible?
    respond_to do |format|
      format.html { render 'status/422', status: 422 }
      format.json do
        render status: 422,
               json: {
                 notifications: [
                   {
                     type: :error,
                     message: "#{convertible_edge.owner} is not convertible"
                   }
                 ]
               }
      end
    end
  end
end
