# frozen_string_literal: true

module RootGrantable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :grants,
                      action_object: true,
                      predicate: NS.argu[:grants]
    end
  end
end
