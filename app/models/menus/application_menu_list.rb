# frozen_string_literal: true

class ApplicationMenuList < LinkedRails::Menus::List
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers
  include UriTemplateHelper

  delegate :afe_request?, :user, to: :user_context

  def available_menus
    return {} if user_context&.system_scope?

    super
  end

  def custom_menu_items(menu_type, resource)
    CustomMenuItem
      .where(menu_type: menu_type, resource_type: resource.class.base_class.name, resource_id: resource.uuid)
      .order(:order)
      .map do |menu_item|
      menu_item(
        "custom_#{menu_item.id}",
        label: menu_item.label,
        image: menu_item.image,
        href: RDF::URI(menu_item.href),
        policy: menu_item.policy
      )
    end
  end

  class << self
    def has_action_menu(opts = {})
      has_menu :actions, {
        image: 'fa-ellipsis-v',
        menus: -> { action_menu_items }
      }.merge(opts)
    end

    def has_follow_menu(opts = {})
      follow_types = opts.delete(:follow_types)
      has_menu :follow, {
        policy: :follow_items?,
        policy_resource: -> { user },
        description: I18n.t('notifications.receive.title'),
        image: -> { follow_menu_icon(follow_type) },
        menus: -> { follow_menu_items(follow_types) }
      }.merge(opts)
    end

    def has_share_menu(opts = {})
      has_menu :share, {
        image: 'fa-share-alt',
        link_opts: -> { opts.merge(iri: resource.iri) },
        menus: -> { share_menu_items }
      }.merge(opts)
    end
  end
end
