# frozen_string_literal: true

module Dismissable
  module Serializer
    extend ActiveSupport::Concern

    included do
      # with_collection :banners, predicate: NS::ONTOLA[:banners]
    end
  end
end
