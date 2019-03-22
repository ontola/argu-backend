# frozen_string_literal: true

module Topicable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :topics, predicate: NS::ARGU[:topics]
    end
  end
end
