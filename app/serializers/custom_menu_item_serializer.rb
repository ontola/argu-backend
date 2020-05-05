# frozen_string_literal: true

class CustomMenuItemSerializer < MenuItemSerializer
  attribute :order, predicate: NS::ARGU[:order]
  attribute :raw_label, predicate: NS::ARGU[:menuLabel], datatype: NS::XSD[:string]
  attribute :raw_image, predicate: NS::ARGU[:rawImage], datatype: NS::XSD[:string]
  attribute :raw_href, predicate: NS::ARGU[:rawHref], datatype: NS::XSD[:string]
  attribute :label_translation, predicate: NS::ARGU[:labelTranslation]

  def action; end

  def data; end

  def menus_present?
    object.custom_menu_items.any?
  end

  def parent_menu?
    object.parent_menu
  end

  def raw_image
    object.attribute_in_database(:image)
  end

  def raw_href
    object.attribute_in_database(:href)
  end

  def raw_label
    object.attribute_in_database(:label)
  end
end
