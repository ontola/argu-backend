# frozen_string_literal: true

module Edgeable
  module Searchable
    extend ActiveSupport::Concern

    included do
      enhance ::Searchable

      with_collection :search_results,
                      association_base: -> { SearchResult::Query.new(self) },
                      association_class: Edge,
                      collection_class: SearchResult::Collection,
                      iri_template_keys: %i[q match],
                      route_key: :search

      include InstanceOverwrites
      extend ClassOverwrites
    end

    module InstanceOverwrites
      def search_data
        preload_properties(force: true)
        data = super
        data[:path] = path
        data[:published_branch] = !has_unpublished_ancestors?
        data
      end

      def searchable_should_index?
        super && is_published?
      end
    end

    module ClassOverwrites
      def allowed_paths(query)
        paths = granted_paths(query)

        parent_granted?(query, paths) ? [query.edge_path] : paths
      end

      def allowed_path_expression(query)
        exp = allowed_paths(query)
                .map { |p| "(#{Regexp.quote(p)}($|\\.[0-9]+)*)" }
                .join('|')
        Regexp.new("\\A#{exp}\\z")
      end

      def default_search_filter(query)
        filter = {}
        filter[:path] = allowed_path_expression(query)
        filter[:published_branch] = true
        filter
      end

      def granted_paths(query)
        return [] if query.user_context.blank?

        query.user_context
          .grant_tree
          .grants_in_scope
          .select { |g| query.user_context.user.profile.group_ids.include?(g.group_id) }
          .map { |g| g.edge.path }
          .uniq
      end

      def parent_granted?(query, paths)
        paths.any? do |p|
          p == query.edge_path || query.edge_path.starts_with?("#{p}.")
        end
      end

      def reindex_with_tenant(async: {wait: true})
        return if Rails.application.config.disable_searchkick

        ActsAsTenant.without_tenant do
          Page.find_each { |page| page.reindex_tree(async: async) }
        end
      rescue StandardError => e
        Bugsnag.notify(e)
      end

      def searchable_aggregations
        [
          RDF[:type].to_s,
          NS.argu[:trashed].to_s,
          NS.argu[:pinned].to_s
        ]
      end
    end
  end
end
