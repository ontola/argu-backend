# frozen_string_literal: true

module Edgeable
  module ClassMethods
    extend ActiveSupport::Concern

    module ClassMethods
      # Hands over publication of a collection to the Community profile
      def anonymize(collection)
        collection.update_all(creator_id: Profile::COMMUNITY_ID) # rubocop:disable Rails/SkipsModelValidations
      end

      def base_class
        Edge
      end

      def collection_include_map
        JSONAPI::IncludeDirective::Parser.parse_include_args(%i[root shortname])
      end

      def edge_includes_for_index
        {
          published_publications: {},
          custom_placement: {place: {}},
          default_cover_photo: {},
          active_motions: {}
        }
      end

      # Hands over ownership of a collection to the Community user
      def expropriate(collection)
        collection.update_all(publisher_id: User::COMMUNITY_ID) # rubocop:disable Rails/SkipsModelValidations
      end

      def includes_for_serializer
        super.merge(
          creator: :profileable,
          parent: {},
          root: {}
        )
      end

      def order_child_count_sql(type, direction: :desc, as: 'edges') # rubocop:disable Naming/MethodParameterName
        column =
          Arel::Nodes::InfixOperation
            .new('->', Edge.arel_table.alias(as)[:children_counts], Arel::Nodes::SqlLiteral.new("'#{type}'"))
        casted = Arel::Nodes::NamedFunction.new('CAST', [column.as('INT')])
        Arel::Nodes::NamedFunction.new('COALESCE', [casted, Arel::Nodes::SqlLiteral.new('0')]).send(direction)
      end

      def sort_options(collection)
        return [NS::SCHEMA[:dateCreated]] if collection.type == :infinite

        [NS::SCHEMA[:name], NS::SCHEMA[:dateCreated]]
      end

      private

      def has_many_children(association, dependent: :destroy, order: {created_at: :asc}, through: nil) # rubocop:disable Metrics/MethodLength
        has_many association,
                 -> { order(order).included_properties },
                 foreign_key: :parent_id,
                 inverse_of: :parent,
                 dependent: dependent,
                 through: through
        has_many "active_#{association}".to_sym,
                 -> { active.order(order).included_properties },
                 class_name: association.to_s.classify,
                 foreign_key: :parent_id,
                 inverse_of: :parent,
                 dependent: dependent,
                 through: through
      end

      def term_property(key, predicate, opts)
        property key, :linked_edge_id, predicate, opts.merge(association_class: 'Term')
      end
    end
  end
end
