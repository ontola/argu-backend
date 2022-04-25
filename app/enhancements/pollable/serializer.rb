# frozen_string_literal: true

module Pollable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :polls, predicate: NS.argu[:polls]
    end
  end
end
