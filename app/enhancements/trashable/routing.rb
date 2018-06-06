# frozen_string_literal: true

module Trashable
  module Routing
    class << self
      def route_concerns(mapper)
        mapper.concern :trashable do
          mapper.member do
            mapper.get :delete, action: :delete, as: :delete
            mapper.delete '', action: :destroy, as: :destroy, constraints: Argu::DestroyConstraint

            mapper.get :trash, action: :bin, as: :trash
            mapper.delete '', action: :trash

            mapper.get :untrash, action: :unbin, as: :untrash
            mapper.put :untrash, action: :untrash
          end
        end
      end
    end
  end
end
