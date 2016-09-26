# frozen_string_literal: true
# Interface for the edge hierarchy.
module Edgeable
  extend ActiveSupport::Concern

  included do
    has_one :edge,
            as: :owner,
            inverse_of: :owner,
            dependent: :destroy,
            required: true
    has_many :grants, through: :edge
    accepts_nested_attributes_for :edge
    delegate :persisted_edge, :last_activity_at, to: :edge

    accepts_nested_attributes_for :edge

    def root_object?
      false
    end

    def pinned
      edge.pinned_at.present?
    end
    alias_method :pinned?, :pinned

    def pinned=(value)
      edge.pinned_at = value == '1' ? DateTime.current : nil
    end
  end
end
