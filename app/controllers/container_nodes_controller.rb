# frozen_string_literal: true

class ContainerNodesController < EdgeableController # rubocop:disable Metrics/ClassLength
  prepend_before_action :redirect_generic_shortnames, only: :show
  skip_before_action :authorize_action, only: %i[discover index]
  skip_before_action :check_if_registered, only: %i[discover index]
  skip_after_action :verify_authorized, only: :discover
  active_response :new

  def discover
    ActsAsTenant.without_tenant do
      @forums =
        Forum
          .public_forums
          .includes(:default_cover_photo, :default_profile_photo, root: :shortname, parent: :shortname)
          .page(show_params[:page])
      skip_verify_policy_scoped(true)
      render
    end
  end

  def show
    return unless policy(resource_by_id).show?
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
        parent_uri_template: :new_container_node_iri,
        title: I18n.t('container_nodes.type_new')
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
    authorize authenticated_resource, :list?

    super
  end

  def collect_children(resource)
    policy_scope(
      resource
        .children
        .where(owner_type: %w[Motion Question])
        .order('edges.pinned_at DESC NULLS LAST, edges.last_activity_at DESC')
    )
      .includes(Question.edge_includes_for_index.deep_merge(Motion.edge_includes_for_index))
      .page(show_params[:page])
      .per(30)
  end

  def controller_classes
    ([ContainerNode] + ContainerNode.descendants)
  end

  def current_forum
    resource_by_id
  end

  def default_form_view(action)
    return action if lookup_context.exists?("container_nodes/#{action}")

    super
  end

  def forum_grants
    @forum_grants ||=
      Grant
        .custom
        .where(edge_id: [authenticated_resource.uuid, authenticated_resource.parent.uuid])
        .includes(group: {group_memberships: {member: :profileable}})
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

  def show_params
    params.permit(:page)
  end

  def signals_failure
    controller_classes.map { |klass| :"#{action_name}_#{klass.name.underscore}_failed" }
  end

  def signals_success
    controller_classes.map { |klass| :"#{action_name}_#{klass.name.underscore}_successful" }
  end

  def tab!
    @verified_tab ||= policy(resource_by_id || Forum).verify_tab(tab)
  end

  def tab
    @tab ||= params[:tab] || params[:forum].try(:[], :tab) || policy(authenticated_resource).default_tab
  end
end
