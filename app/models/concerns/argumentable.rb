# frozen_string_literal: true
module Argumentable
  extend ActiveSupport::Concern

  included do
    edge_tree_has_many :arguments, -> { argument_comments }
    edge_tree_has_many :top_arguments_con, (lambda do
      argument_comments
        .joins(:edge)
        .where(pro: false)
        .untrashed
        .order("cast(edges.children_counts -> 'votes_pro' AS int) DESC NULLS LAST")
        .limit(5)
    end), class_name: 'Argument'
    edge_tree_has_many :top_arguments_pro, (lambda do
      argument_comments
        .joins(:edge)
        .where(pro: true)
        .untrashed
        .order("cast(edges.children_counts -> 'votes_pro' AS int) DESC NULLS LAST")
        .limit(5)
    end), class_name: 'Argument'
    edge_tree_has_many :arguments_plain, -> { all }, class_name: 'Argument'

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
