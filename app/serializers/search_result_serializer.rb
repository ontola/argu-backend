# frozen_string_literal: true

class SearchResultSerializer < CollectionSerializer
  attribute :took, predicate: NS::ARGU[:took]
  attribute :query, predicate: NS::ONTOLA[:query]

  def query
    object.q || ''
  end
end
