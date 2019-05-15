# frozen_string_literal: true

module Argumentable
  module Routing; end

  class << self
    def dependent_classes
      [Argument]
    end

    def route_concerns(mapper)
      mapper.concern :argumentable do
        mapper.resources :arguments, only: %i[new create]
        mapper.resources :pro_arguments, only: %i[new create index], path: 'pros', defaults: {pro: 'pro'} do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
        mapper.resources :con_arguments, only: %i[new create index], path: 'cons', defaults: {pro: 'con'} do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end
