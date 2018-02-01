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
    edge_tree_has_many :pro_arguments, lambda {
      where(type: 'ProArgument')
        .order(
          Arel.sql("cast(COALESCE(edges.children_counts -> 'votes_pro', '0') AS int)") => :desc,
          Arel.sql('edges.last_activity_at') => :desc
        )
    }, source_type: 'Argument'
    edge_tree_has_many :con_arguments, lambda {
      where(type: 'ConArgument')
        .order(
          Arel.sql("cast(COALESCE(edges.children_counts -> 'votes_pro', '0') AS int)") => :desc,
          Arel.sql('edges.last_activity_at') => :desc
        )
    }, source_type: 'Argument'

    with_collection :pro_arguments, pagination: true
    with_collection :con_arguments, pagination: true

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
      # rubocop:disable Rails/HasManyOrHasOneDependent
      has_one :pro_argument_collection, predicate: NS::ARGU[:proArguments]
      has_one :con_argument_collection, predicate: NS::ARGU[:conArguments]
      # rubocop:enable Rails/HasManyOrHasOneDependent

      def pro_argument_collection
        object.pro_argument_collection(user_context: scope)
      end

      def con_argument_collection
        object.con_argument_collection(user_context: scope)
      end
    end
  end
end
