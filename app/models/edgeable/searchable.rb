# frozen_string_literal: true

module Edgeable
  module Searchable
    extend ActiveSupport::Concern

    included do
      enhance ::Searchable
      include InstanceOverwrites
      extend ClassOverwrites
    end

    module InstanceOverwrites
      def search_data
        preload_properties(true)
        data = super
        data[:path] = path
        data[:published_branch] = !has_unpublished_ancestors?
        data
      end

      def search_result(opts = {})
        SearchResult.new(
          opts.merge(
            parent: self,
            association_class: Edge,
            parent_uri_template: :search_results_iri,
            parent_uri_template_canonical: :search_results_iri
          )
        )
      end

      def searchable_should_index?
        super && is_published?
      end
    end

    module ClassOverwrites
      def allowed_paths(search_result)
        paths = granted_paths(search_result)

        parent_granted?(search_result, paths) ? [search_result.parent.path] : paths
      end

      def allowed_path_expression(search_result)
        exp = allowed_paths(search_result)
                .map { |p| "(#{Regexp.quote(p)}($|\\.[0-9]+)*)" }
                .join('|')
        Regexp.new("\\A#{exp}\\z")
      end

      def default_search_filter(search_result)
        filter = {}
        filter[:path] = allowed_path_expression(search_result)
        filter[:published_branch] = true
        filter
      end

      def granted_paths(search_result) # rubocop:disable Metrics/AbcSize
        return [] if search_result.user_context.blank?

        search_result.user_context
          .grant_tree
          .grants_in_scope
          .select { |g| search_result.user_context.user.profile.group_ids.include?(g.group_id) }
          .map { |g| g.edge.path }
          .uniq
      end

      def parent_granted?(search_result, paths)
        paths.any? do |p|
          p == search_result.parent.path || search_result.parent.path.starts_with?("#{p}.")
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
          NS::ARGU[:trashed].to_s,
          NS::ARGU[:pinned].to_s
        ]
      end
    end
  end
end
