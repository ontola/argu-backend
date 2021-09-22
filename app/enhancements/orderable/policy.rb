# frozen_string_literal: true

module Orderable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes %i[position]
    end

    def move_up?
      update?
    end

    def move_down?
      update?
    end
  end
end
