# frozen_string_literal: true

module Dismissable
  module Routing; end

  class << self
    def dependent_classes
      [BannerDismissal]
    end

    def route_concerns(mapper)
      mapper.concern :dismissable do
        mapper.resources :banner_dismissals, only: %i[new create]
      end
    end
  end
end
