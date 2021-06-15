# frozen_string_literal: true

module Offerable
  module Routing; end

  class << self
    def dependent_classes
      [Offer, Order]
    end

    def route_concerns(mapper)
      mapper.concern :offerable do
        mapper.resource :cart, only: %i[show], path: :cart do
          mapper.resources :cart_details, only: %i[index new]
        end
        mapper.resources :orders, only: %i[index new create]
        mapper.resources :offers, only: %i[index new create]
      end
    end
  end
end
