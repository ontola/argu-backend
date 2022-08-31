# frozen_string_literal: true

class GrantedGroup < VirtualResource
  collection_options(
    association_base: -> { GrantedGroup.collection_items(self) }
  )
  filterable(
    NS.argu[:selectable] => boolean_filter(
      ->(scope) { scope.where(deletable: true) },
      ->(scope) { scope.where(deletable: false) }
    )
  )

  class << self
    def collection_items(collection)
      granted = collection.user_context.grant_tree.granted_groups(collection.parent)
      granted.any?(&:users?) ? Group.all : granted
    end

    def requested_index_resource(params, user_context)
      parent = parent_from_params(params, params[:user_context]) || ActsAsTenant.current_tenant

      default_collection_option(:collection_class).collection_or_view(
        default_collection_options.merge(parent: parent),
        index_collection_params(params, user_context)
      )
    end

    def collection_route_key
      :granted
    end

    def route_key
      Group.route_key
    end
  end
end
