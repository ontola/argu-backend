# frozen_string_literal: true

module Inviteable
  module Routing; end

  class << self
    def route_concerns(mapper)
      mapper.concern :inviteable do
        resources :invites, only: %i[new]
      end
    end
  end
end
