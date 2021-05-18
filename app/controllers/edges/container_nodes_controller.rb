# frozen_string_literal: true

class ContainerNodesController < EdgeableController
  prepend_before_action :redirect_generic_shortnames, only: :show
  active_response :new

  def show
    return unless policy(requested_resource).show?

    super
  end

  private

  def actions_collection
    @actions_collection ||= ::Collection.new(
      collection_options.merge(
        association_base: actions_array,
        association_class: ::Actions::Item,
        default_display: :grid,
        default_type: :paginated,
        parent_uri_template: :new_container_node_iri
      )
    )
  end

  def actions_array
    ContainerNode
      .descendants
      .map { |container| container.root_collection(parent: ActsAsTenant.current_tenant).action(:create, user_context) }
      .select(&:available?)
  end

  def authorize_action
    authorize(authenticated_resource, :list?) unless action_name == 'index'

    super
  end

  def controller_classes
    ([ContainerNode] + ContainerNode.descendants)
  end

  def current_forum
    requested_resource
  end

  def model_name
    controller_classes.map { |klass| klass.name.underscore }.detect { |k| params.key?(k) }
  end

  def new_success
    return super unless self.class == ContainerNodesController

    respond_with_collection(index_success_options_rdf.merge(collection: collection_or_view(actions_collection)))
  end

  def photo_params_nesting_path
    []
  end

  def redirect_generic_shortnames
    return if (/[a-zA-Z]/i =~ params[:id]).nil?

    resource = Shortname.find_resource(params[:id], tree_root_id) || raise(ActiveRecord::RecordNotFound)
    return if resource.is_a?(ContainerNode)

    redirect_to resource.iri
  end

  def signals_failure
    controller_classes.map { |klass| :"#{action_name}_#{klass.name.underscore}_failed" }
  end

  def signals_success
    controller_classes.map { |klass| :"#{action_name}_#{klass.name.underscore}_successful" }
  end

  def update_success
    return super unless current_resource.previous_changes.key?(:url)

    respond_with_redirect(location: current_resource.iri, reload: true)
  end
end
