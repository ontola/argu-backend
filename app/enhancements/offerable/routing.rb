# frozen_string_literal: true

module Offerable
  module Routing; end

  class << self
    def dependent_classes
      [Offer, Order]
    end

    def route_concerns(mapper) # rubocop:disable Metrics/MethodLength
      mapper.concern :offerable do
        mapper.resource :cart, only: %i[show], path: :cart do
          mapper.resources :cart_details, only: %i[index new]
        end
        mapper.resources :orders, only: %i[new create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
        mapper.resources :offers, only: %i[index new create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end
