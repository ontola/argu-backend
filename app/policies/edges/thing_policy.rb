# frozen_string_literal: true

class ThingPolicy < EdgePolicy
  delegate :show?, to: :parent_policy
end
