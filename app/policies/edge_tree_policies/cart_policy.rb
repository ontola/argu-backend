# frozen_string_literal: true

class CartPolicy < EdgeTreePolicy
  delegate :show?, to: :edgeable_policy
end
