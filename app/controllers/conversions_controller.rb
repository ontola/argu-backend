# frozen_string_literal: true

class ConversionsController < ServiceController
  active_response :new, :create

  include ConvertibleHelper
  before_action :verify_convertible_edge

  private

  def active_response_action(opts)
    opts[:resource].action(user_context, :create)
  end

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
    authorize parent_resource!, :convert?
    authorize authenticated_resource, :new?
  end

  def collect_banners; end

  def create_service_parent
    Conversion.new(edge: parent_resource!)
  end

  def create_success_options
    opts = super
    opts[:resource] = authenticated_resource.edge
    opts
  end

  def current_forum
    @current_forum ||= resource_by_id&.ancestor(:forum)
  end

  def resource_by_id; end

  def redirect_location
    authenticated_resource.is_a?(Edge) ? authenticated_resource.iri_path : authenticated_resource.edge.iri_path
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
                     message: "#{parent_resource!} is not convertible"
                   }
                 ]
               }
      end
    end
  end
end
