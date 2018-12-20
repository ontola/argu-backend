# frozen_string_literal: true

module Menuable
  module Routing
    class << self
      def route_concerns(mapper)
        mapper.concern :menuable do
          mapper.resources :menus, only: %i[index show] do
            mapper.resources :sub_menus, only: :index, path: 'menus'
          end
        end
      end
    end
  end
end
