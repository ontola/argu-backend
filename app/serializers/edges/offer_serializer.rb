# frozen_string_literal: true

class OfferSerializer < ContentEdgeSerializer
  extend UriTemplateHelper
  has_one :default_cover_photo, predicate: NS.ontola[:coverPhoto]
  attribute :cart_detail, predicate: NS.argu[:cartDetail] do |object|
    CartDetail.new(parent: object).singular_iri
  end
end
