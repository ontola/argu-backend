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

    def root_object?
      false
    end

    # @private
    def naming_context
      return @naming_context if @naming_context.present?
      ancestors = (new_record? ? edge.parent.self_and_ancestors : edge.self_and_ancestors)
                    .select { |edge| edge.owner.respond_to? :uses_alternative_names }
      @naming_context = (ancestors.detect { |edge| edge.owner.try(:uses_alternative_names) } ||
                         ancestors.last)
                          .owner
    end
  end
end
