# frozen_string_literal: true

module Motionable
  extend ActiveSupport::Concern

  included do
    with_collection :motions, pagination: true
  end

  module Actions
    extend ActiveSupport::Concern
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :motions, predicate: NS::ARGU[:motions]

      def motion_collection
        object.motion_collection(user_context: scope)
      end
    end
  end
end
