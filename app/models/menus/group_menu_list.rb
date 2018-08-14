# frozen_string_literal: true

class GroupMenuList < MenuList
  include SettingsHelper
  cattr_accessor :defined_menus
  has_menus %i[settings]

  private

  def settings_menu
    menu_item(
      :settings,
      iri_base: ->(only_path) { resource.iri(only_path: only_path) },
      menus: lambda {
        [
          setting_item(
            :members,
            href: collection_iri(resource, :group_memberships)
          ),
          setting_item(
            :invite,
            href: collection_iri(resource, :tokens, token_type: :email, group_id: resource.id)
          ),
          setting_item(
            :general,
            href: edit_iri(resource)
          ),
          setting_item(
            :grants,
            href: collection_iri(resource, :grants)
          ),
          setting_item(
            :delete,
            href: delete_iri(resource)
          )
        ]
      }
    )
  end
end
