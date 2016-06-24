# Interface for the edge hierarchy.
module Edgeable
  extend ActiveSupport::Concern

  included do
    has_one :edge,
            as: :owner,
            inverse_of: :owner,
            dependent: :destroy,
            required: true,
            autosave: true
    before_update :update_edge_parent, if: :parent_changed?

    private

    def parent_changed?
      false
    end

    def update_edge_parent
      edge.update(parent: parent_edge)
    end
  end
end
