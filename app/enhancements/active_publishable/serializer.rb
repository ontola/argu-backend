# frozen_string_literal: true

module ActivePublishable
  module Serializer
    extend ActiveSupport::Concern

    included do
      has_one :argu_publication, predicate: NS.argu[:arguPublication]
    end
  end
end
