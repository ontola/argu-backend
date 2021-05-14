# frozen_string_literal: true

module CustomActionable
  module Routing; end

  class << self
    def dependent_classes
      [CustomAction]
    end

    def route_concerns(mapper)
      mapper.concern :custom_actionable do
        mapper.resources :custom_actions, only: %i[index new create]
      end
    end
  end
end
