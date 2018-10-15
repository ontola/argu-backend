# frozen_string_literal: true

class MenuItemSerializer < BaseSerializer
  attribute :action, predicate: NS::ARGU[:action]
  attribute :label, predicate: NS::SCHEMA[:name]
  attribute :href, predicate: NS::ARGU[:href]
  attribute :data

  has_one :parent, predicate: NS::ARGU[:parentMenu], if: :has_parent_menu?
  has_one :resource, predicate: NS::SCHEMA[:isPartOf]

  has_one :menu_sequence, predicate: NS::ARGU[:menuItems], if: :menus_present?
  has_one :image, predicate: NS::SCHEMA[:image]

  def data
    object.link_opts.try(:[], :data)
  end

  def has_parent_menu?
    object.parent.is_a?(MenuItem)
  end

  def href
    object.href && RDF::URI(object.href)
  end

  def image
    serialize_image(object.image)
  end

  def menus_present?
    object.menu_sequence.members.present?
  end

  def type
    object.type || NS::ARGU[:MenuItem]
  end
end
