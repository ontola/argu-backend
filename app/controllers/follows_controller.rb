# frozen_string_literal: true

class FollowsController < AuthorizedController
  PERMITTED_CLASSES = %w[Forum Question Motion Argument Comment BlogPost].freeze
  skip_before_action :check_if_registered, if: :unsubscribe?
  skip_before_action :authorize_action, if: :unsubscribe?
  skip_before_action :verify_authenticity_token, if: :unsubscribe?

  private

  def create_meta
    authenticated_resource
      .followable
      .menu(user_context, :follow)
      .menu_sequence
      .members
      .map(&method(:menu_item_image_triple))
  end

  def destroy_failure_html
    return destroy_failure if request.method == 'DELETE'
    render 'destroy', locals: {unsubscribed: false}
  end

  def destroy_failure_rdf
    respond_with_redirect(
      location: authenticated_resource.followable.iri,
      notice: t('notifications.unsubscribe.failed', item: authenticated_resource.followable.display_name)
    )
  end

  def destroy_success_html
    return destroy_success if request.method == 'DELETE'
    render 'destroy', locals: {unsubscribed: true}
  end

  def destroy_success_rdf
    respond_with_redirect(
      location: authenticated_resource.followable.iri,
      notice: t('notifications.unsubscribe.success', item: authenticated_resource.followable.display_name)
    )
  end

  def destroy_execute
    return true if request.head?
    @unsubscribed = !authenticated_resource.never? && authenticated_resource.never!
  end

  def index_collection_name; end

  def active_response_success_message
    t('notifications.changed_successfully')
  end

  def menu_item_image_triple(menu_item)
    [
      menu_item.iri,
      NS::SCHEMA[:image],
      RDF::URI("http://fontawesome.io/icon/#{menu_item.image.gsub('fa-', '')}"), NS::ARGU[:replace]
    ]
  end

  def new_resource_from_params # rubocop:disable Metrics/AbcSize
    return @resource if instance_variable_defined?(:@resource)
    followable = Edge.where(owner_type: PERMITTED_CLASSES).find_by(uuid: permit_params[:gid])
    return @resource = nil if followable.nil?
    @resource = current_user.follows.find_or_initialize_by(
      followable_id: followable.uuid,
      followable_type: 'Edge'
    )
    @resource.follow_type = action_name == 'create' ? permit_params[:follow_type] || :reactions : :never
    @resource
  end

  def permit_params
    params.permit %i[follow_type gid]
  end

  def redirect_location
    authenticated_resource.followable.iri
  end

  def unsubscribe?
    action_name == 'destroy' && request.method != 'DELETE'
  end
end
