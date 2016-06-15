# Interface for the edge hierarchy.
module Edgeable
  extend ActiveSupport::Concern

  included do
    has_one :edge,
            as: :owner,
            inverse_of: :owner,
            dependent: :destroy
    before_create :build_edge
    after_initialize :cache_parent
    before_update :update_edge_parent, if: :parent_changed?

    def build_edge
      if respond_to?(:parent_model)
        super(parent: parent_model.edge)
      else
        super
      end
    end

    private

    def cache_parent
      @parent_was = parent_model if respond_to?(:parent_model)
    end

    def parent_changed?
      return false unless respond_to?(:parent_model)
      @parent_was != parent_model
    end

    def update_edge_parent
      edge.update(parent: parent_model.edge)
    end
  end
end
