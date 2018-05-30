# frozen_string_literal: true

module Edgeable
  module ClassMethods
    extend ActiveSupport::Concern

    module ClassMethods
      # Hands over publication of a collection to the Community profile
      def anonymize(collection)
        collection.update_all(creator_id: Profile::COMMUNITY_ID)
      end

      def edge_includes_for_index
        {
          published_publications: {},
          custom_placements: {place: {}},
          default_cover_photo: {},
          active_motions: {}
        }
      end

      # Hands over ownership of a collection to the Community user
      def expropriate(collection)
        collection.update_all(publisher_id: User::COMMUNITY_ID)
      end

      def path_array(relation)
        return 'NULL' if relation.blank?
        unless relation.is_a?(ActiveRecord::Relation)
          raise "Relation should be a ActiveRecord relation, but is a #{relation.class.name}"
        end
        paths = relation.map(&:path)
        paths.each { |path| paths.delete_if { |p| p.match(/^#{path}\./) } }
        "ARRAY[#{paths.map { |path| "'#{path}.*'::lquery" }.join(',')}]"
      end

      def show_trashed(show_trashed = nil)
        show_trashed ? where(nil) : untrashed
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
        if klass < Edge
          options[:includes] ||= {
            creator: {profileable: :shortname},
            parent: {}
          }
          options[:includes][:votes] = {} if klass <= Argument
          options[:includes][:comment_children] = {} if klass == Comment
          options[:includes][:default_vote_event] = %i[creator] if klass == Motion
          options[:includes][:published_publications] = {} if klass.reflect_on_association(:published_publications)
          options[:includes][:default_cover_photo] = {} if klass.reflect_on_association(:default_cover_photo)
          options[:collection_class] = EdgeableCollection
        end
        super
      end
    end
  end
end
