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

  module Actions
    extend ActiveSupport::Concern

    included do
      include ActionableHelper

      define_action :pro_argument
      define_action :con_argument

      def pro_argument_action
        action_item(
          :create_pro_argument,
          target: pro_argument_entrypoint,
          resource: resource.pro_argument_collection(user_context: user_context),
          result: ProArgument,
          type: [
            NS::ARGU[:CreateAction],
            NS::ARGU[:CreateProArgument]
          ],
          policy: :pro_argument?
        )
      end

      def pro_argument_entrypoint
        entry_point_item(
          :create_pro_argument,
          image: 'fa-plus',
          url: collection_create_url(:pro_argument),
          http_method: 'POST'
        )
      end

      def con_argument_action
        action_item(
          :create_con_argument,
          target: con_argument_entrypoint,
          resource: resource_collection(:con_argument),
          result: ConArgument,
          type: [
            NS::ARGU[:CreateAction],
            NS::ARGU[:CreateConArgument]
          ],
          policy: :con_argument?
        )
      end

      def con_argument_entrypoint
        entry_point_item(
          :create_con_argument,
          image: 'fa-plus',
          url: collection_create_url(:con_argument),
          http_method: 'POST'
        )
      end
    end
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :pro_arguments, predicate: NS::ARGU[:proArguments]
      with_collection :con_arguments, predicate: NS::ARGU[:conArguments]
    end
  end
end
