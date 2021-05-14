# frozen_string_literal: true

module Bannerable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :banners, predicate: NS::ONTOLA[:banners]
      with_collection :banner_managements, predicate: NS::ONTOLA[:bannersManagement]
    end
  end
end
