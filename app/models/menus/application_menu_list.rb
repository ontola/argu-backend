# frozen_string_literal: true

class ApplicationMenuList < LinkedRails::Menus::List
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers
  include UriTemplateHelper
  include LinkedRails::Helpers::OntolaActionsHelper

  delegate :afe_request?, :user, to: :user_context

  def available_menus
    return {} if user_context&.system_scope?

    super
  end

  private

  def default_label(tag, options)
    LinkedRails.translations(
      -> { I18n.t("menus.#{resource&.class&.name&.tableize}.#{tag}", options[:label_params]) }
    )
  end

  def copy_share_link(url)
    menu_item(
      :copy,
      action: ontola_copy_action(url),
      item_type: 'copy',
      image: 'fa-clipboard',
      href: url
    )
  end

  def custom_menu_items(menu_type, resource)
    scoped_menu_items(menu_type, resource)
  end

  def scoped_menu_items(menu_type, resource)
    Pundit.policy_scope!(
      user_context,
      CustomMenuItem
        .where(menu_type: menu_type, resource_type: resource.class.base_class.name, resource_id: resource.uuid)
        .order(:order)
    )
  end

  def widgets_link
    menu_item(
      :widgets,
      href: resource.widget_collection.iri(display: :table),
      image: 'fa-th',
      policy: :create_child?,
      policy_arguments: [:widgets]
    )
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
        description: I18n.t('notifications.receive.title'),
        image: 'fa-bell-o',
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
