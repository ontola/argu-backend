# frozen_string_literal: true

class OfferSerializer < ContentEdgeSerializer
  has_one :product, predicate: NS::SCHEMA.itemOffered
  has_one :default_cover_photo, predicate: NS::ONTOLA[:coverPhoto]
end
