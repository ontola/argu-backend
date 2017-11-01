# frozen_string_literal: true

module Motionable
  extend ActiveSupport::Concern

  module Serializer
    extend ActiveSupport::Concern
    included do
      has_one :motion_collection, predicate: RDF::ARGU[:motions]

      def motion_collection
        object.motion_collection(user_context: scope)
      end
    end
  end
end
