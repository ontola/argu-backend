# frozen_string_literal: true

class MenuItemSerializer < BaseSerializer
  attribute :label, predicate: NS::ARGU[:label]
  attribute :href, predicate: NS::ARGU[:href]
  attribute :data

  has_one :parent, predicate: NS::SCHEMA[:isPartOf]

  has_one :menu_sequence, predicate: NS::ARGU[:menuItems], if: :menus_present?
  has_one :image, predicate: NS::SCHEMA[:image]

  def data
    object.link_opts.try(:[], :data)
  end

  def image
    serialize_image(object.image)
  end

  def type
    return object.type if object.type.present?
    return NS::ARGU["#{object.tag.capitalize}Menu"] if object.parent.is_a?(MenuList)
    object.menus.present? ? NS::ARGU[:SubMenu] : NS::ARGU[:MenuItem]
  end

  def menus_present?
    object.menu_sequence.members.present?
  end
end
