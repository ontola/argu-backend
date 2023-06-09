# frozen_string_literal: true

module CreativeWorkable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :creative_works, predicate: NS.argu[:creative_works]
    end
  end
end
