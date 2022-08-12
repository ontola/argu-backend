# frozen_string_literal: true

module SwipeToolable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :swipe_tools
    end
  end
end
