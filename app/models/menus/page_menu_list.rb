# frozen_string_literal: true

class PageMenuList < ApplicationMenuList
  include SettingsHelper
  include Menus::ActionMenuItems

  has_menu :navigations,
           menus: -> { navigations_menu_items }
  has_menu :settings,
           iri_base: -> { resource.iri_path },
           menus: -> { setting_menu_items }

  private

  def container_nodes
    @container_nodes ||=
      EdgePolicy::Scope.new(user_context, resource.container_nodes)
        .resolve
        .includes(:default_profile_photo, :shortname)
  end

  def new_container_node_item
    menu_item(
      :new_component,
      image: 'fa-plus',
      policy: :create_child?,
      policy_arguments: %i[forums],
      href: RDF::DynamicURI(path_with_hostname(expand_uri_template(:new_container_node_iri)))
    )
  end

  def navigations_menu_items
    [
      menu_item(
        :home,
        image: resource.home_menu_image,
        label: resource.home_menu_label,
        href: resource.iri
      ),
      *custom_menu_items(:navigations, resource),
      menu_item(
        :settings,
        image: 'fa-gear',
        href: settings_iri(resource),
        policy: :update?
      ),
      new_container_node_item
    ]
  end

  def navigation_item(record)
    menu_item(
      record.url.to_sym,
      href: record.iri,
      label: record.display_name,
      image: record.try(:default_profile_photo),
      policy: :show?,
      policy_resource: record
    )
  end

  def setting_menu_items # rubocop:disable Metrics/AbcSize
    [
      setting_item(:general, label: I18n.t('pages.settings.menu.general'), href: edit_iri(resource)),
      setting_item(
        :container_nodes,
        label: I18n.t('pages.settings.menu.container_nodes'),
        href: collection_iri(resource, :container_nodes, display: :settingsTable)
      ),
      setting_item(
        :groups,
        label: I18n.t('pages.settings.menu.groups'),
        href: collection_iri(resource, :groups, display: :settingsTable)
      ),
      setting_item(
        :shortnames,
        label: I18n.t('pages.settings.menu.shortnames'),
        href: collection_iri(resource, :shortnames, display: :settingsTable)
      ),
      setting_item(
        :custom_menu_items,
        label: I18n.t('custom_menu_items.plural'),
        href: collection_iri(resource, :custom_menu_items, display: :table)
      ),
      setting_item(
        :banners,
        label: I18n.t('banners.plural'),
        href: collection_iri(resource, :banners, display: :table)
      )
    ]
  end
end
