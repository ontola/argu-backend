# frozen_string_literal: true

module Feedable
  module Routing; end

  class << self
    def route_concerns(mapper)
      mapper.concern :feedable do
        get :feed, controller: :feed, action: :index
      end
    end
  end
end
