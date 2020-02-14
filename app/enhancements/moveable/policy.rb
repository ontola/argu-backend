# frozen_string_literal: true

module Moveable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      attributes = super
      attributes.append(:move_to_edge_id)
      attributes
    end

    def move?
      staff? || administrator? || moderator?
    end
  end
end
