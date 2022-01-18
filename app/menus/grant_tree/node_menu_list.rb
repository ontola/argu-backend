# frozen_string_literal: true

class GrantTree
  class NodeMenuList < ApplicationMenuList
    has_tabs_menu

    private

    def children_link
      menu_item(
        :children,
        label: I18n.t('menus.grants.children.item'),
        href: resource.collection_iri(
          :permission_groups,
          display: :settingsTable,
          title: I18n.t('menus.grants.children.collection')
        )
      )
    end

    def grants_link
      menu_item(
        :grants,
        label: I18n.t('menus.grants.grants.item'),
        href: resource.collection_iri(:grants, display: :table, table_type: :grant_tree)
      )
    end

    def grant_resets_link
      menu_item(
        :grant_resets,
        label: I18n.t('menus.grants.grant_resets.item'),
        href: resource.collection_iri(
          :grant_resets,
          display: :table,
          title: I18n.t('menus.grants.grant_resets.collection')
        )
      )
    end

    def resource_link
      menu_item(
        :resource,
        label: I18n.t('menus.grants.resource.item'),
        href: resource.collection_iri(
          :permission_groups,
          display: :table,
          title: I18n.t('menus.grants.resource.collection')
        )
      )
    end

    def tabs_menu_items
      [
        resource_link,
        children_link,
        grants_link,
        grant_resets_link
      ]
    end
  end
end
