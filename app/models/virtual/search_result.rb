# frozen_string_literal: true

class SearchResult < VirtualResource
  class << self
    def root_collection?
      true
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
