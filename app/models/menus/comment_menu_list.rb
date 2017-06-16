# frozen_string_literal: true
class CommentMenuList < MenuList
  include SettingsHelper
  cattr_accessor :defined_menus
  has_menus %i()
end
