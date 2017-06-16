# frozen_string_literal: true
class MotionMenuList < MenuList
  include SettingsHelper
  cattr_accessor :defined_menus
  has_menus %i()
end
