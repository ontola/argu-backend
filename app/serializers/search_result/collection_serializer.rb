# frozen_string_literal: true

class SearchResult
  class CollectionSerializer < ::CollectionSerializer
    attribute :placeholder, predicate: NS.form[:placeholder]
    attribute :took, predicate: NS.argu[:took]
    attribute :query, predicate: NS.ontola[:query] do |object|
      object.q || ''
    end
  end
end
