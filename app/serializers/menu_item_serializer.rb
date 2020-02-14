# frozen_string_literal: true

class MenuItemSerializer < LinkedRails::Menus::ItemSerializer
  has_one :image, predicate: NS::SCHEMA[:image]

  def href
    object.href.is_a?(String) ? RDF::URI(object.href) : object.href
  end

  def image
    serialize_image(object.image)
  end

  def type
    object.try(:type) || NS::ONTOLA[:MenuItem]
  end
end
