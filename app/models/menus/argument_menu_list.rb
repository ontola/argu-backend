# frozen_string_literal: true
class ArgumentMenuList < MenuList
  include SettingsHelper
  cattr_accessor :defined_menus
  has_menus %i()
end
