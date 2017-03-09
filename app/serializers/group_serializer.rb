# frozen_string_literal: true
class GroupSerializer < BaseEdgeSerializer
  attribute :name, key: :displayName

  has_one :creator do
    nil
  end
end
