# frozen_string_literal: true

class ConversionsController < ServiceController
  active_response :new, :create

  include ConvertibleHelper
  before_action :verify_convertible_edge

  private

  def authenticated_resource!
    @authenticated_resource ||=
      case action_name
      when 'create'
        create_service.resource
      when 'new'
        new_resource_from_params
      end
  end

  def authorize_action
    return authorize parent_resource!, :show? if form_action?

    authorize parent_resource!, :convert?
    authorize authenticated_resource, :new?
  end

  def create_service_parent
    Conversion.new(edge: parent_resource!)
  end

  def create_success_options
    opts = super
    opts[:resource] = authenticated_resource.edge
    opts
  end

  def current_forum
    @current_forum ||= requested_resource&.ancestor(:forum)
  end

  def requested_resource; end

  def redirect_location
    authenticated_resource.is_a?(Edge) ? authenticated_resource.iri : authenticated_resource.edge.iri
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
    raise "#{parent_resource!} is not convertible" unless parent_resource!.is_convertible?
  end
end
