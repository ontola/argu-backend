# frozen_string_literal: true

module Discussable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :discussions, predicate: NS::ARGU[:questions]
    end
  end
end
