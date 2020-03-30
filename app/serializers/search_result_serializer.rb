# frozen_string_literal: true

class SearchResultSerializer < BaseSerializer
  has_one :parent, predicate: NS::SCHEMA[:isPartOf]
  has_one :results, predicate: NS::AS[:items]
  attribute :name, predicate: NS::AS[:name]
  attribute :total_count, predicate: NS::AS[:totalItems]
  attribute :took, predicate: NS::ARGU[:took]
  attribute :q, predicate: NS::ARGU[:query]
  attribute :display, predicate: NS::ONTOLA[:collectionDisplay]
  attribute :search_template, predicate: NS::ONTOLA[:iriTemplate]
  attribute :search_template_opts, predicate: NS::ONTOLA[:iriTemplateOpts]
  attribute :sort_options, predicate: NS::ONTOLA[:sortOptions]
  has_many :sortings, predicate: NS::ONTOLA[:collectionSorting]

  %i[first prev next last].each do |attr|
    attribute attr, predicate: NS::AS[attr], unless: :system_scope?
  end

  def display
    NS::ONTOLA['collectionDisplay/grid']
  end

  def type
    NS::ARGU[:SearchResult]
  end
end
