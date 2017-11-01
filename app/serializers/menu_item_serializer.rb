# frozen_string_literal: true

class MenuItemSerializer < BaseSerializer
  attribute :label, predicate: RDF::ARGU[:label]
  attribute :href, predicate: RDF::ARGU[:href]
  attribute :data

  has_one :parent, predicate: RDF::SCHEMA[:isPartOf]

  has_many :menus, predicate: RDF::ARGU[:menuItems]
  has_one :image, predicate: RDF::SCHEMA[:image] do
    obj = object.image
    if obj
      if obj.is_a?(MediaObject)
        obj
      elsif obj.is_a?(String)
        obj = obj.gsub(/^fa-/, 'http://fontawesome.io/icon/')
        {
          id: obj,
          type: RDF::ARGU[:FontAwesomeIcon]
        }
      end
    end
  end

  def data
    object.link_opts.try(:[], :data)
  end
end
