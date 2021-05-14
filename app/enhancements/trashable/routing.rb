# frozen_string_literal: true

module Trashable
  module Routing; end

  class << self
    def route_concerns(mapper)
      mapper.concern :trashable do
        mapper.member do
          mapper.get :delete, action: :delete
          mapper.delete '', action: :destroy, constraints: Argu::DestroyConstraint

          mapper.get :trash, action: :bin
          mapper.delete '', action: :trash

          mapper.get :untrash, action: :unbin
          mapper.put :untrash, action: :untrash
        end
      end
    end
  end
end
