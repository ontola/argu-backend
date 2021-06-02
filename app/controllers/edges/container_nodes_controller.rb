# frozen_string_literal: true

class ContainerNodesController < EdgeableController
  prepend_before_action :redirect_generic_shortnames, only: :show

  def show
    return unless policy(requested_resource).show?

    super
  end

  private

  def authorize_action
    authorize(authenticated_resource, :list?) unless action_name == 'index'

    super
  end

  def controller_classes
    ([ContainerNode] + ContainerNode.descendants)
  end

  def model_name
    controller_classes.map { |klass| klass.name.underscore }.detect { |k| params.key?(k) }
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
