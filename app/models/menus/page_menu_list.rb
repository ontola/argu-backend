# frozen_string_literal: true

class PageMenuList < MenuList
  include SettingsHelper
  include Menus::ActionMenuItems
  cattr_accessor :defined_menus
  has_menus %i[navigations settings]

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
      policy: :create_child?,
      policy_arguments: %i[forums],
      menus: lambda {
        %i[forum open_data_portal].map do |container_type|
          menu_item(
            :"new_#{container_type}",
            href: new_iri(resource, container_type.to_s.pluralize),
            policy: :create_child?,
            policy_arguments: [container_type]
          )
        end
      }
    )
  end

  def navigations_menu
    menu_item(
      :navigations,
      menus: lambda {
        [
          menu_item(
            :overview,
            image: 'fa-th-large',
            href: resource.iri
          ),
          *container_nodes.map { |child| navigation_item(child) },
          *custom_menu_items(:navigations, resource),
          activity_link,
          menu_item(
            :settings,
            image: 'fa-gear',
            href: settings_iri(resource),
            policy: :update?
          ),
          new_container_node_item
        ]
      }
    )
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

  def settings_menu # rubocop:disable Metrics/AbcSize
    menu_item(
      :settings,
      iri_base: -> { resource.iri_path },
      menus: lambda {
        [
          setting_item(:profile, label: I18n.t('pages.settings.menu.general'), href: edit_iri(resource.profile)),
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
          setting_item(:advanced, label: I18n.t('pages.settings.menu.advanced'), href: edit_iri(resource)),
          setting_item(
            :shortnames,
            label: I18n.t('pages.settings.menu.shortnames'),
            href: collection_iri(resource, :shortnames, display: :settingsTable)
          )
        ]
      }
    )
  end
end
