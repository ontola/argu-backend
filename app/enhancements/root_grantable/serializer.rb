# frozen_string_literal: true

module RootGrantable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :grants, predicate: NS::ARGU[:grants]
    end
  end
end
