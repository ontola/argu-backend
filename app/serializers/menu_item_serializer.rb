# frozen_string_literal: true

class MenuItemSerializer < LinkedRails::Menus::ItemSerializer
  attribute :data
  has_one :image, predicate: NS::SCHEMA[:image]

  def data
    object.link_opts.try(:[], :data)
  end

  def href
    object.href.is_a?(String) ? RDF::DynamicURI(object.href) : object.href
  end

  def image
    serialize_image(object.image)
  end

  def type
    object.try(:type) || NS::ONTOLA[:MenuItem]
  end
end
