# frozen_string_literal: true

class MenuItemSerializer < BaseSerializer
  attribute :label, predicate: NS::ARGU[:label]
  attribute :href, predicate: NS::ARGU[:href]
  attribute :data

  has_one :parent, predicate: NS::SCHEMA[:isPartOf]

  has_many :menus, predicate: NS::ARGU[:menuItems]
  has_one :image, predicate: NS::SCHEMA[:image] do
    obj = object.image
    if obj
      if obj.is_a?(MediaObject)
        obj
      elsif obj.is_a?(String)
        obj = RDF::URI(obj.gsub(/^fa-/, 'http://fontawesome.io/icon/'))
        {
          id: obj,
          type: NS::ARGU[:FontAwesomeIcon]
        }
      end
    end
  end

  def data
    object.link_opts.try(:[], :data)
  end

  def type
    return object.type if object.type.present?
    return NS::ARGU["#{object.tag.capitalize}Menu"] if object.parent.is_a?(MenuList)
    object.menus.present? ? NS::ARGU[:SubMenu] : NS::ARGU[:MenuItem]
  end
end
