# frozen_string_literal: true

class GroupSerializer < BaseEdgeSerializer
  has_one :creator, predicate: NS::SCHEMA[:creator] do
    nil
  end
end
