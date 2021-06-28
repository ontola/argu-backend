# frozen_string_literal: true

module Offerable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :offers, predicate: NS.argu[:offers]
      with_collection :orders, predicate: NS.argu[:orders]
    end
  end
end
