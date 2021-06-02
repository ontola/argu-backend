# frozen_string_literal: true

class GroupMenuList < ApplicationMenuList
  include SettingsHelper

  has_menu :settings,
           iri_base: -> { resource.root_relative_iri },
           menus: -> { settings_menu_items }

  private

  def settings_menu_items # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    [
      setting_item(:members, href: collection_iri(resource, :group_memberships, display: :settingsTable)),
      setting_item(
        :email_invite,
        href: collection_iri(resource, :tokens, token_type: :email, group_id: resource.id, display: :settingsTable)
      ),
      setting_item(
        :bearer_invite,
        href: collection_iri(resource, :tokens, token_type: :bearer, group_id: resource.id, display: :settingsTable)
      ),
      setting_item(:general, href: edit_iri(resource)),
      setting_item(:grants, href: collection_iri(resource, :grants, display: :settingsTable)),
      setting_item(:delete, href: delete_iri(resource))
    ]
  end
end
