# frozen_string_literal: true

class ForumMenuList < ContainerNodeMenuList
  cattr_accessor :defined_menus

  has_menus %i[actions follow navigations share]
end
