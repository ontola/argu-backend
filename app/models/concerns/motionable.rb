# frozen_string_literal: true
module Motionable
  extend ActiveSupport::Concern

  included do
    def motion_collection(opts = {})
      Collection.new(
        {
          parent: self,
          association: :motions,
          pagination: true
        }.merge(opts)
      )
    end
  end

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
    end
  end
end
