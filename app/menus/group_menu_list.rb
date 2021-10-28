# frozen_string_literal: true

class GroupMenuList < ApplicationMenuList
  include SettingsHelper

  has_menu :settings,
           image: 'fa-ellipsis-v',
           iri_base: -> { resource.root_relative_iri },
           menus: -> { settings_menu_items }

  private

  def settings_menu_items # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    [
      setting_item(:members, href: resource.collection_iri(:group_memberships, display: :settingsTable)),
      setting_item(
        :email_invite,
        href: iri_from_template(
          :tokens_collection_iri,
          token_type: :email,
          group_id: resource.id,
          display: :settingsTable
        )
      ),
      setting_item(
        :bearer_invite,
        href: iri_from_template(
          :tokens_collection_iri,
          token_type: :bearer,
          group_id: resource.id,
          display: :settingsTable
        )
      ),
      setting_item(:general, href: edit_iri(resource)),
      setting_item(:grants, href: resource.collection_iri(:grants, display: :settingsTable)),
      setting_item(:delete, href: delete_iri(resource))
    ]
  end
end
