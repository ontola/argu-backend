# frozen_string_literal: true

module Buyable
  module Routing; end

  class << self
    def dependent_classes
      [CartDetail]
    end

    def route_concerns(mapper)
      mapper.concern :buyable do
        mapper.resource :cart_details, only: %i[new create destroy] do
          mapper.get :delete, action: :delete
          include_route_concerns
        end
      end
    end
  end
end
