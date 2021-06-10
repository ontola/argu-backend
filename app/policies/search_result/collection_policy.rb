# frozen_string_literal: true

class SearchResult
  class CollectionPolicy < ::CollectionPolicy
    def show?
      true
    end

    def public_resource?
      true
    end
  end
end
