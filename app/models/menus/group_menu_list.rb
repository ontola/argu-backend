# frozen_string_literal: true

class GroupMenuList < MenuList
  include SettingsHelper
  cattr_accessor :defined_menus
  has_menus %i[settings]

  private

  def settings_menu # rubocop:disable Metrics/AbcSize
    menu_item(
      :settings,
      iri_base: -> { resource.iri_path },
      menus: lambda {
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
      }
    )
  end
end
