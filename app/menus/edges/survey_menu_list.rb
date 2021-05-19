# frozen_string_literal: true

class SurveyMenuList < ApplicationMenuList
  include Helpers::FollowMenuItems
  include Helpers::ShareMenuItems
  include Helpers::ActionMenuItems

  has_action_menu
  has_follow_menu
  has_share_menu

  private

  def action_menu_items
    [
      edit_link,
      external_link,
      move_link,
      new_update_link,
      copy_share_link(resource.iri),
      *trash_and_destroy_links
    ]
  end

  def external_link
    return unless resource.manage_iri

    menu_item(
      :external,
      image: 'fa-external-link',
      label: I18n.t('menus.default.typeform'),
      href: resource.manage_iri,
      policy: :update?
    )
  end
end
