# frozen_string_literal: true

module Topicable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :topics, predicate: NS.argu[:topics]
    end
  end
end
