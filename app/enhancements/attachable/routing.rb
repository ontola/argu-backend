# frozen_string_literal: true

module Attachable
  module Routing
    class << self
      def route_concerns(mapper)
        mapper.concern :attachable do
          mapper.resources :media_objects, path: :attachments, only: :index, defaults: {used_as: :attachment}
        end
      end
    end
  end
end
