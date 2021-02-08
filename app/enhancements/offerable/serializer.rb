# frozen_string_literal: true

module Offerable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :offers, predicate: NS::ARGU[:offers]
      with_collection :orders, predicate: NS::ARGU[:orders]
    end
  end
end
