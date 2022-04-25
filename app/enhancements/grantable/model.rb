# frozen_string_literal: true

module Grantable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :grants
    end

    def granted_sets_iri
      base_iri = is_a?(Edge) ? persisted_edge&.iri : ActsAsTenant.current_tenant&.iri

      RDF::URI("#{base_iri}/grant_sets") if base_iri&.uri?
    end

    def grant_tree_node(user_context)
      @grant_tree_node ||= user_context&.grant_tree&.find_or_cache_node(self)
    end
  end
end
