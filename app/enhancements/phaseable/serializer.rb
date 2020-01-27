# frozen_string_literal: true

module Phaseable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :phases, predicate: NS::ARGU[:phases]
    end
  end
end
