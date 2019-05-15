# frozen_string_literal: true

module Decisionable
  module Routing; end

  class << self
    def dependent_classes
      [Decision]
    end

    def route_concerns(mapper)
      mapper.concern :decisionable do
        mapper.resources :decisions, path: 'decision', only: %i[show new create index], concerns: %i[menuable] do
          mapper.include_route_concerns
          mapper.get :log, action: :log
        end
      end
    end
  end
end
