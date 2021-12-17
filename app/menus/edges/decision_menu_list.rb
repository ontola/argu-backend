# frozen_string_literal: true

class DecisionMenuList < ApplicationMenuList
  include SettingsHelper

  has_action_menu

  private

  def action_menu_items
    [edit_link, copy_share_link(resource.iri)]
  end
end
