# frozen_string_literal: true

module Moveable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes %i[new_parent_id]
    end

    def move?
      staff? || administrator? || moderator?
    end
  end
end
