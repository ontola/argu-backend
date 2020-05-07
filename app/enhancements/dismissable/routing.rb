# frozen_string_literal: true

module Dismissable
  module Routing; end

  class << self
    def dependent_classes
      [BannerDismissal]
    end

    def route_concerns(mapper)
      mapper.concern :dismissable do
        mapper.resources :banner_dismissals, only: %i[new create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end
