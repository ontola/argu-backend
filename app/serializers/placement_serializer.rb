# frozen_string_literal: true

class PlacementSerializer < RecordSerializer
  include NamesHelper

  has_one :image, predicate: NS::SCHEMA[:image]
  has_one :place, predicate: NS::SCHEMA[:geo]
  has_one :placeable, predicate: NS::ARGU[:placeable]

  attribute :country_code, predicate: NS::SCHEMA[:addressCountry]
  attribute :placement_type, predicate: NS::ARGU[:placementType]
  attribute :postal_code, predicate: NS::SCHEMA[:postalCode]

  def image
    image =
      if object.placement_type == 'custom'
        "fa-#{icon_for(object.placeable)}"
      elsif object.placement_type == 'home'
        :home
      end

    serialize_image(image)
  end
end
