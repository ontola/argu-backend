# frozen_string_literal: true

module Topicable
  module Routing; end

  class << self
    def dependent_classes
      [Thread]
    end

    def route_concerns(mapper)
      mapper.concern :topicable do
        mapper.resources :topics, path: 't', only: %i[index new create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end
