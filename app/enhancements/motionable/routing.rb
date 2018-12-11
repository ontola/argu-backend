# frozen_string_literal: true

module Motionable
  module Routing
    class << self
      def dependent_classes
        [Motion]
      end

      def route_concerns(mapper)
        mapper.concern :motionable do
          mapper.resources :motions, path: 'm', only: %i[index new create] do
            mapper.collection do
              mapper.resources :action_items, path: 'actions', only: %i[index show], collection: :motions
            end
          end
        end
      end
    end
  end
end
