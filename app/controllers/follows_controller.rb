# frozen_string_literal: true

class FollowsController < AuthorizedController
  include URITemplateHelper

  skip_before_action :check_if_registered, only: :destroy

  has_collection_create_action(
    description: -> { I18n.t('actions.follows.create.description', item: resource.parent.display_name) }
  )
  has_resource_destroy_action(
    favorite: true
  )

  private

  def create_meta
    followable_menu
      .menu_sequence
      .members
      .map(&method(:menu_item_image_triple))
      .compact + [menu_item_image_triple(followable_menu)]
  end

  def destroy_failure
    respond_with_redirect(
      location: authenticated_resource.followable.iri,
      notice: I18n.t('notifications.unsubscribe.failed', item: authenticated_resource.followable.display_name)
    )
  end

  def destroy_success # rubocop:disable Metrics/MethodLength
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

    !authenticated_resource.never? && authenticated_resource.never!
  end

  def active_response_success_message
    I18n.t('notifications.changed_successfully')
  end

  def followable_menu
    @followable_menu ||= authenticated_resource.followable.menu(:follow, user_context)
  end

  def menu_item_image_triple(menu_item)
    return if menu_item.image.blank?

    [
      menu_item.iri,
      NS.schema.image,
      font_awesome_iri(menu_item.image),
      delta_iri(:replace)
    ]
  end

  def permit_params
    return {} unless action_name == 'create'
    return super if params.key?(:follow)

    {
      follow_type: params.require(:follow_type)
    }
  end

  def redirect_location
    authenticated_resource.followable.iri
  end
end
