# frozen_string_literal: true

class SearchResultSerializer < BaseSerializer
  has_one :parent, predicate: NS::SCHEMA[:isPartOf]
  has_one :results, predicate: NS::AS[:items]
  attribute :total_count, predicate: NS::AS[:totalItems]
  attribute :took, predicate: NS::ARGU[:took]
  attribute :q, predicate: NS::ARGU[:query]

  %i[first prev next last].each do |attr|
    attribute attr, predicate: NS::AS[attr], unless: :system_scope?
  end

  def type
    NS::ARGU[:SearchResult]
  end
end
