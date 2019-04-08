# frozen_string_literal: true

module Datasettable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :datasets, predicate: NS::DCAT[:dataset]
    end
  end
end
