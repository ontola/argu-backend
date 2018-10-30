# frozen_string_literal: true

module Decisionable
  module Serializer
    extend ActiveSupport::Concern

    included do
      has_one :last_published_decision, predicate: NS::ARGU[:decision]
    end
  end
end
