# frozen_string_literal: true

module Trashable
  module Routing; end

  class << self
    def route_concerns(mapper)
      mapper.concern :trashable do
        mapper.member do
          mapper.delete '', action: :destroy, constraints: Argu::DestroyConstraint
          mapper.delete '', action: :trash
          mapper.put :untrash, action: :untrash
        end
      end
    end
  end
end
