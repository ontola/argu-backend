# frozen_string_literal: true

class MenuItemSerializer < BaseSerializer
  attributes :label, :href, :data

  has_one :parent

  has_many :menus do
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

  has_one :image do
    obj = object.image
    if obj
      link(:self) do
        {
          meta: {
            '@type': 'http://schema.org/image'
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
