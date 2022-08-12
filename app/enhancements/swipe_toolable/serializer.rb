# frozen_string_literal: true

module SwipeToolable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :swipe_tools, predicate: NS.argu[:swipeTools]
    end
  end
end
