# frozen_string_literal: true

class MenuItemSerializer < BaseSerializer
  attribute :label, predicate: RDF::ARGU[:label]
  attribute :href, predicate: RDF::ARGU[:href]
  attribute :data

  has_one :parent

  has_many :menus, predicate: RDF::ARGU[:menuItems] do
    link(:self) do
      {
        meta: {
          '@type': 'argu:menuItems'
        }
      }
    end
    meta do
      {
        '@type': 'argu:menuItems'
      }
    end
  end

  has_one :image, predicate: RDF::SCHEMA[:image] do
    obj = object.image
    if obj
      link(:self) do
        {
          meta: {
            '@type': RDF::SCHEMA[:image]
          }
        }
      end
      if obj.is_a?(MediaObject)
        link(:related) do
          {
            href: obj.context_id,
            meta: {
              '@type': obj.context_type
            }
          }
        end
        obj
      elsif obj.is_a?(String)
        obj = obj.gsub(/^fa-/, 'http://fontawesome.io/icon/')
        link(:related) do
          {
            href: obj,
            meta: {
              '@type': 'argu:FontAwesomeIcon'
            }
          }
        end
        {
          id: obj,
          type: 'argu:FontAwesomeIcon'
        }
      end
    end
  end

  def data
    object.link_opts.try(:[], :data)
  end
end
