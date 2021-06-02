# frozen_string_literal: true

class SearchResult < VirtualResource
  class << self
    def parent_from_params(params, user_context)
      super(params.except(:page, :before), user_context)
    end

    def root_collection_class
      SearchResult::Collection
    end

    def root_collection_opts
      super.merge(
        association_class: Edge,
        parent: ActsAsTenant.current_tenant
      )
    end
  end
end
