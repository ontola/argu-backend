# frozen_string_literal: true

module Distributable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :distributions, predicate: NS::DCAT[:distribution]
      has_many :samples, predicate: NS::ADMS[:sample]
    end
  end
end
