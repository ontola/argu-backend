# frozen_string_literal: true

module Argumentable
  extend ActiveSupport::Concern

  included do
    edge_tree_has_many :arguments, lambda {
      order(
        Arel.sql("cast(COALESCE(edges.children_counts -> 'votes_pro', '0') AS int)") => :desc,
        Arel.sql('edges.last_activity_at') => :desc
      )
    }

    with_collection :arguments, pagination: true

    def invert_arguments
      false
    end

    def invert_arguments=(invert)
      return if invert == '0'
      Motion.transaction do
        arguments.each do |a|
          a.update_attributes pro: !a.pro
        end
      end
    end
  end

  module Serializer
    extend ActiveSupport::Concern
    included do
      has_one :argument_collection do
        link(:self) do
          {
            href: "#{object.context_id}/arguments",
            meta: {
              '@type': 'argu:arguments'
            }
          }
        end
        meta do
          href = object.context_id
          {
            '@type': 'argu:collectionAssociation',
            '@id': "#{href}/arguments"
          }
        end
      end

      def argument_collection
        object.argument_collection(user_context: scope)
      end
    end
  end
end
