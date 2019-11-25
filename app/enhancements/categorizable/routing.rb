# frozen_string_literal: true

module Categorizable
  module Routing; end

  class << self
    def route_concerns(mapper)
      mapper.concern :categorizable do
        mapper.resources :categories, path: 'categories', only: %i[new index create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end
