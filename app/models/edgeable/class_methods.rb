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
        {
          creator: :profileable,
          parent: {}
        }
      end

      def order_child_count_sql(type, direction: :desc, as: 'edges')
        column =
          Arel::Nodes::InfixOperation
            .new('->', Edge.arel_table.alias(as)[:children_counts], Arel::Nodes::SqlLiteral.new("'#{type}'"))
        casted = Arel::Nodes::NamedFunction.new('CAST', [column.as('INT')])
        Arel::Nodes::NamedFunction.new('COALESCE', [casted, Arel::Nodes::SqlLiteral.new('0')]).send(direction)
      end

      def preview_includes
        super + [creator: Profile.preview_includes]
      end

      def reindex_with_tenant(async: {wait: true})
        ActsAsTenant.without_tenant do
          Page.find_each { |page| page.reindex_tree(async: async) }
        end
      end

      # Selects edges of a certain type over persisted and transient models.
      # @param [String] type The (child) edges' #owner_type value
      # @param [Hash] where_clause Filter options for the owners of the edge akin to activerecords' `where`.
      # @option where_clause [Integer, #confirmed?] :creator :publisher If the object is not `#confirmed?`,
      #         the system will use transient resources.
      # @return [ActiveRecord::Relation, RedisResource::Relation]
      def where_owner(type, where_clause = {})
        if where_clause[:publisher]&.guest? || where_clause[:creator]&.profileable&.guest?
          RedisResource::EdgeRelation.where(where_clause.merge(owner_type: type))
        else
          type.constantize.where(where_clause)
        end
      end

      private

      def has_many_children(association, dependent: :destroy, order: {created_at: :asc})
        has_many association,
                 -> { order(order).includes(:properties) },
                 foreign_key: :parent_id,
                 inverse_of: :parent,
                 dependent: dependent
        has_many "active_#{association}".to_sym,
                 -> { active.order(order).includes(:properties) },
                 class_name: association.to_s.classify,
                 foreign_key: :parent_id,
                 inverse_of: :parent,
                 dependent: dependent
      end

      def with_collection(name, options = {})
        klass = options[:association_class] || name.to_s.classify.constantize
        options[:association] ||= "active_#{name}" if klass < Edge
        super
      end
    end
  end
end
