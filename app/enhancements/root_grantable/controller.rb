# frozen_string_literal: true

module RootGrantable
  module Controller
    extend ActiveSupport::Concern

    def update_meta
      return super unless current_resource.previously_changed_relations.key?(:grant_collection)

      super + GrantTree::PermissionGroup.invalidate_all_delta
    end
  end
end
