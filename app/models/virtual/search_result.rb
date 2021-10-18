# frozen_string_literal: true

class SearchResult < VirtualResource
  collection_options(
    association_class: Edge,
    collection_class: SearchResult::Collection,
    iri_template_keys: %i[q match],
    parent: -> { ActsAsTenant.current_tenant },
    route_key: :search
  )

  class << self
    def parent_from_params(params, user_context)
      super(params.except(:page, :before), user_context)
    end
  end
end
