# frozen_string_literal: true

module Questionable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :questions, predicate: NS::ARGU[:questions]
    end
  end
end
