# frozen_string_literal: true

class FollowsController < AuthorizedController
  PERMITTED_CLASSES = Edge.descendants.select { |klass| klass.enhanced_with?(Followable) }.freeze
  skip_before_action :check_if_registered, only: :destroy
  prepend_before_action :set_tenant

  private

  def create_meta
    followable_menu
      .menu_sequence
      .members
      .map(&method(:menu_item_image_triple))
      .compact
  end

  def destroy_failure_rdf
    respond_with_redirect(
      location: authenticated_resource.followable.iri,
      notice: I18n.t('notifications.unsubscribe.failed', item: authenticated_resource.followable.display_name)
    )
  end

  def destroy_success_rdf
    add_exec_action_header(
      headers,
      ontola_snackbar_action(
        I18n.t('notifications.unsubscribe.success', item: authenticated_resource.followable.display_name)
      )
    )
    add_exec_action_header(
      headers,
      ontola_redirect_action(authenticated_resource.followable.iri)
    )
    head 200
  end

  def destroy_execute
    return true if request.head?

    @unsubscribed = !authenticated_resource.never? && authenticated_resource.never!
  end

  def collection_from_parent_name; end

  def active_response_success_message
    I18n.t('notifications.changed_successfully')
  end

  def find_params
    params.permit %i[follow_type gid]
  end

  def followable_menu
    @followable_menu ||= authenticated_resource.followable.menu(:follow, user_context)
  end

  def menu_item_image_triple(menu_item)
    return if menu_item.image.blank?

    [
      menu_item.iri,
      NS::SCHEMA[:image],
      RDF::URI("http://fontawesome.io/icon/#{menu_item.image.gsub('fa-', '')}"),
      delta_iri(:replace)
    ]
  end

  def new_resource_from_params # rubocop:disable Metrics/AbcSize
    return @resource if instance_variable_defined?(:@resource)
    followable = Edge.find_by(uuid: find_params[:gid])
    return @resource = nil if followable.nil? || PERMITTED_CLASSES.detect { |klass| followable.is_a?(klass) }.nil?
    @resource = current_user.follows.find_or_initialize_by(
      followable_id: followable.uuid,
      followable_type: 'Edge'
    )
    @resource.follow_type = action_name == 'create' ? find_params[:follow_type] || :reactions : :never
    @resource
  end

  def permit_params
    {}
  end

  def set_tenant
    ActsAsTenant.current_tenant ||= authenticated_resource.followable.root
  end

  def redirect_location
    authenticated_resource.followable.iri
  end
end
