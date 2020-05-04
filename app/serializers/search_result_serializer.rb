# frozen_string_literal: true

class SearchResultSerializer < CollectionSerializer
  attribute :placeholder, predicate: NS::ONTOLA[:placeholder]
  attribute :took, predicate: NS::ARGU[:took]
  attribute :query, predicate: NS::ONTOLA[:query]

  def query
    object.q || ''
  end
end
