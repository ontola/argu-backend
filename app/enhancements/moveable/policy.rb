# frozen_string_literal: true

module Moveable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes %i[move_to_edge_id]
    end

    def move?
      staff? || administrator? || moderator?
    end
  end
end
