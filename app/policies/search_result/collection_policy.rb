# frozen_string_literal: true

class SearchResult
  class CollectionPolicy < ::CollectionPolicy
    def show?
      return staff? unless public_resource?

      true
    end

    def public_resource?
      record.parent.try(:association_class) != User
    end
  end
end
