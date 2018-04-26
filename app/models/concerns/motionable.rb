# frozen_string_literal: true

module Motionable
  extend ActiveSupport::Concern

  included do
    with_collection :motions, pagination: true
  end

  module Actions
    extend ActiveSupport::Concern

    included do
      include ActionableHelper

      define_action :motion

      def motion_action
        action_item(
          :create_motion,
          target: motion_entrypoint,
          resource: resource.motion_collection,
          result: Motion,
          type: [
            NS::ARGU[:CreateAction],
            NS::SCHEMA[:MotionAction],
            NS::ARGU[:CreateMotion]
          ],
          policy: :motion?
        )
      end

      def motion_entrypoint
        entry_point_item(
          :create_motion,
          image: 'fa-motion',
          url: collection_create_url(:motion),
          http_method: 'POST'
        )
      end
    end
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
