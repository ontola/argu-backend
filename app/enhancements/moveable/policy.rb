# frozen_string_literal: true

module Moveable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes %i[new_parent_id]
    end

    def move?
      return false unless moderator? || administrator? || staff?
      return forbid_wrong_tier unless feature_enabled?(:move_content)

      true
    end
  end
end
