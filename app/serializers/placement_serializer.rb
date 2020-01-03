# frozen_string_literal: true

class PlacementSerializer < RecordSerializer
  include NamesHelper

  has_one :image, predicate: NS::SCHEMA[:image]
  has_one :place, predicate: NS::SCHEMA[:geo]
  has_one :placeable, predicate: NS::ARGU[:placeable]

  attribute :country_code, predicate: NS::SCHEMA[:addressCountry]
  attribute :placement_type, predicate: NS::ARGU[:placementType]
  attribute :postal_code, predicate: NS::SCHEMA[:postalCode]

  attribute :lat,
            predicate: NS::SCHEMA[:latitude],
            if: :export_scope?
  attribute :lon,
            predicate: NS::SCHEMA[:longitude],
            if: :export_scope?

  def image
    image =
      if object.placement_type == 'custom'
        icon = icon_for(object.placeable)
        :"fa-#{icon}" if icon
      elsif object.placement_type == 'home'
        :'fa-home'
      end

    serialize_image(image) if image
  end
end
