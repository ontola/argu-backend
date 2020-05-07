# frozen_string_literal: true

module Bannerable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :banners, predicate: NS::ONTOLA[:banners]
    end
  end
end
