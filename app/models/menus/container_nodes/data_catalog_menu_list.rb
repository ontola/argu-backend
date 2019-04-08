# frozen_string_literal: true

class DataCatalogMenuList < ContainerNodeMenuList
  cattr_accessor :defined_menus

  has_menus %i[actions follow navigations share]
end
