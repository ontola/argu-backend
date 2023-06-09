# frozen_string_literal: true

class CustomMenuItemSerializer < Menus::ItemSerializer
  attribute :action, predicate: NS.ontola[:action] do
    nil
  end
  has_one :action, predicate: NS.ontola[:action] do
    nil
  end
  has_one :edge, predicate: NS.argu[:edge]
  attribute :position, predicate: NS.argu[:order]
  attribute :raw_label, predicate: NS.argu[:menuLabel], datatype: NS.xsd.string do |object|
    object.attribute_in_database(:label)
  end
  attribute :icon, predicate: NS.argu[:icon], datatype: NS.xsd.string do |object|
    object.attribute_in_database(:image)
  end
  attribute :raw_href, predicate: NS.argu[:rawHref], datatype: NS.xsd.string do |object|
    object.attribute_in_database(:href)
  end
  attribute :custom_image, predicate: NS.argu[:customImage], &:custom_image_iri
  attribute :custom_image_content_type, predicate: NS.schema.encodingFormat
  has_one :parent,
          predicate: NS.ontola[:parentMenu],
          if: ->(o, p) { parent_menu?(o, p) },
          polymorphic: true
  has_one :menu_sequence,
          predicate: NS.ontola[:menuItems],
          if: ->(o, p) { menus_present?(o, p) },
          polymorphic: true
  enum :target_type, predicate: NS.argu[:targetType]

  def self.menus_present?(object, _params)
    object.menus_present?
  end

  def self.parent_menu?(object, _params)
    object.parent_menu
  end
end
