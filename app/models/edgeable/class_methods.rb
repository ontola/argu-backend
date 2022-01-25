# frozen_string_literal: true

module Edgeable
  module ClassMethods
    extend ActiveSupport::Concern

    module ClassMethods
      # Hands over publication of a collection to the Community profile
      def anonymize(collection)
        collection.update_all(creator_id: Profile::COMMUNITY_ID) # rubocop:disable Rails/SkipsModelValidations
      end

      def attributes_for_new(opts) # rubocop:disable Metrics/MethodLength
        parent = opts[:parent] if opts[:parent].is_a?(Edge)
        attrs = {
          owner_type: name,
          parent: parent,
          persisted_edge: opts[:parent].try(:persisted_edge)
        }
        user_context = opts[:user_context]
        attrs[:publisher] = user_context&.user || User.new(show_feed: true)
        attrs[:creator] = user_context&.profile
        attrs[:session_id] = user_context&.session_id
        attrs
      end

      def base_class
        Edge
      end

      def build_new(parent: nil, user_context: nil)
        record = super
        grant_tree = user_context&.grant_tree
        grant_tree&.cache_node(record.parent.try(:persisted_edge)) if record.parent.try(:persisted_edge)
        record
      end

      def collection_from_parent_name(parent, params)
        return :tagging_collection if params[:collection] == :taggings
        return :favorite_page_collection if parent.is_a?(User)

        super
      end

      # Hands over ownership of a collection to the Community user
      def expropriate(collection)
        collection.update_all(publisher_id: User::COMMUNITY_ID) # rubocop:disable Rails/SkipsModelValidations
      end

      def order_child_count_sql(type, direction: :desc, as: 'edges') # rubocop:disable Naming/MethodParameterName
        column =
          Arel::Nodes::InfixOperation
            .new('->', Edge.arel_table.alias(as)[:children_counts], Arel::Nodes::SqlLiteral.new("'#{type}'"))
        casted = Arel::Nodes::NamedFunction.new('CAST', [column.as('INT')])
        Arel::Nodes::NamedFunction.new('COALESCE', [casted, Arel::Nodes::SqlLiteral.new('0')]).send(direction)
      end

      def requested_single_resource(params, _user_context)
        if uuid?(params[:id])
          Edge.find_by(uuid: params[:id])
        else
          Edge.find_by(fragment: params[:id])
        end
      end

      def sort_options(collection)
        return [NS.schema.dateCreated] if collection.type == :infinite

        [NS.schema.name, NS.schema.dateCreated]
      end

      private

      def has_many_children(association, dependent: :destroy, order: {created_at: :asc}, through: nil) # rubocop:disable Metrics/MethodLength
        opts = {
          class_name: association.to_s.classify,
          foreign_key: :parent_id,
          inverse_of: :parent,
          dependent: dependent
        }
        opts[:through] = through if through

        # rubocop:disable Rails/InverseOf
        has_many association,
                 -> { order(order) },
                 **opts
        has_many "active_#{association}".to_sym,
                 -> { active.order(order) },
                 **opts
        # rubocop:enable Rails/InverseOf
      end

      def ids_for_iris(scope)
        scope
          .left_joins(:shortname)
          .skip_preloading!
          .select('edges.uuid', 'edges.fragment', 'shortnames.shortname')
          .map(&:to_param)
      end

      def term_property(key, predicate, **opts)
        property key, :linked_edge_id, predicate, **opts.merge(association_class: 'Term')
      end

      def valid_collection_option?(key)
        super || key == :counter_cache_column
      end
    end
  end
end
