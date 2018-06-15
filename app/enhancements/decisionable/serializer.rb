# frozen_string_literal: true

module Decisionable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :decisions, predicate: NS::ARGU[:decisions]
    end
  end
end
