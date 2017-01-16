# frozen_string_literal: true
module Motionable
  extend ActiveSupport::Concern

  module Serlializer
    extend ActiveSupport::Concern
    included do
      has_one :motion_collection do
        link(:self) do
          {
            href: "#{object.context_id}/motions",
            meta: {
              '@type': 'argu:motions'
            }
          }
        end
        meta do
          href = object.context_id
          {
            '@type': 'argu:collectionAssociation',
            '@id': "#{href}/motions"
          }
        end
      end

      def motion_collection
        object.motion_collection(user_context: scope)
      end
    end
  end
end
