# frozen_string_literal: true

module Commentable
  module Serializer
    extend ActiveSupport::Concern

    included do
      count_attribute :comments
      with_collection :comments, predicate: NS.schema.comment
      has_one :top_comment, predicate: NS.argu[:topComment]
    end
  end
end
