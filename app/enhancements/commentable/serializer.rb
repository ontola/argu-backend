# frozen_string_literal: true

module Commentable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :comments, predicate: NS::SCHEMA[:comments]
    end
  end
end
