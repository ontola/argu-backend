# frozen_string_literal: true

class OfferPolicy < EdgePolicy
  permit_attributes %i[price product_id]
end
