# frozen_string_literal: true

module Edgeable
  module ClassMethods
    extend ActiveSupport::Concern

    module ClassMethods
      # Hands over publication of a collection to the Community profile
      def anonymize(collection)
        collection.update_all(creator_id: Profile::COMMUNITY_ID) # rubocop:disable Rails/SkipsModelValidations
      end

      def attributes_for_new(opts)
        parent = opts[:parent] if opts[:parent].is_a?(Edge)
        attrs = {
          owner_type: name,
          parent: parent,
          persisted_edge: opts[:parent].try(:persisted_edge)
        }
        user_context = opts[:user_context]
        attrs[:publisher] = user_context&.user || User.new(show_feed: true)
        attrs[:creator] = user_context&.profile unless user_context&.profile&.guest?
        attrs
      end

      def base_class
        Edge
      end

      def build_new(opts)
        record = super
        grant_tree = opts[:user_context]&.grant_tree
        grant_tree&.cache_node(record.parent.try(:persisted_edge)) if record.parent.try(:persisted_edge)
        record
      end

      def collection_from_parent_name(parent, params)
        return :tagging_collection if params[:collection] == :taggings
        return :favorite_page_collection if parent.is_a?(User)

        super
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

      def root_collection_opts
        super.merge(parent: ActsAsTenant.current_tenant)
      end

      def sort_options(collection)
        return [NS.schema.dateCreated] if collection.type == :infinite

        [NS.schema.name, NS.schema.dateCreated]
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
