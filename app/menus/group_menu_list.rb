# frozen_string_literal: true

class GroupMenuList < ApplicationMenuList
  include SettingsHelper

  has_menu :settings,
           image: 'fa-ellipsis-v',
           iri_base: -> { resource.root_relative_iri },
           label: -> { I18n.t('menu') },
           menus: -> { settings_menu_items }

  private

  def settings_menu_items # rubocop:disable Metrics/MethodLength
    [
      setting_item(
        :members,
        dialog: true,
        href: resource.collection_iri(:group_memberships, display: :settingsTable)
      ),
      setting_item(
        :email_invite,
        dialog: true,
        href: invite_email_url
      ),
      setting_item(
        :bearer_invite,
        dialog: true,
        href: invite_bearer_url
      ),
      setting_item(
        :edit,
        dialog: true,
        href: edit_iri(resource)
      ),
      setting_item(
        :grants,
        dialog: true,
        href: resource.collection_iri(:grants, display: :settingsTable)
      ),
      setting_item(
        :delete,
        dialog: true,
        href: delete_iri(resource)
      )
    ]
  end

  def invite_bearer_url
    iri_from_template(
      :tokens_collection_iri,
      token_type: :bearer,
      group_id: resource.id,
      display: :settingsTable
    )
  end

  def invite_email_url
    iri_from_template(
      :tokens_collection_iri,
      token_type: :email,
      group_id: resource.id,
      display: :settingsTable
    )
  end
end
