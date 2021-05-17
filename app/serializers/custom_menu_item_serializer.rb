# frozen_string_literal: true

class CustomMenuItemSerializer < MenuItemSerializer
  attribute :action, predicate: NS::ONTOLA[:action] do
    nil
  end
  has_one :action, predicate: NS::ONTOLA[:action], polymorphic: true do
    nil
  end
  attribute :order, predicate: NS::ARGU[:order]
  attribute :raw_label, predicate: NS::ARGU[:menuLabel], datatype: NS::XSD[:string] do |object|
    object.attribute_in_database(:label)
  end
  attribute :raw_image, predicate: NS::ARGU[:rawImage], datatype: NS::XSD[:string] do |object|
    object.attribute_in_database(:image)
  end
  attribute :raw_href, predicate: NS::ARGU[:rawHref], datatype: NS::XSD[:string] do |object|
    object.attribute_in_database(:href)
  end
  attribute :label_translation, predicate: NS::ARGU[:labelTranslation]
  has_one :parent,
          predicate: NS::ONTOLA[:parentMenu],
          if: ->(o, p) { parent_menu?(o, p) },
          polymorphic: true
  has_one :menu_sequence,
          predicate: NS::ONTOLA[:menuItems],
          if: ->(o, p) { menus_present?(o, p) },
          polymorphic: true

  def self.menus_present?(object, _params)
    object.menus_present?
  end

  def self.parent_menu?(object, _params)
    object.parent_menu
  end
end
