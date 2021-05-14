# frozen_string_literal: true

module Interventionable
  module Routing; end

  class << self
    def dependent_classes
      [Intervention]
    end

    def route_concerns(mapper)
      mapper.concern :interventionable do
        mapper.resources :interventions, path: 'interventies', only: %i[new index create]
      end
    end
  end
end
