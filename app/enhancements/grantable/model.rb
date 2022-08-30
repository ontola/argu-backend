# frozen_string_literal: true

module Grantable
  module Model
    extend ActiveSupport::Concern
    include URITemplateHelper

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

    def permissions_iri
      LinkedRails.iri(path: permissions_root_relative_iri)
    end

    def permissions_root_relative_iri
      GrantTree::Node.singular_iri_template.expand(parent_iri: split_iri_segments(root_relative_iri))
    end

    def permission_groups_iri
      LinkedRails.iri(path: permission_groups_root_relative_iri)
    end

    def permission_groups_root_relative_iri
      GrantTree::PermissionGroup.iri_template.expand(parent_iri: split_iri_segments(permissions_root_relative_iri))
    end
  end
end
