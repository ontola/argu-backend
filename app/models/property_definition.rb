# frozen_string_literal: true

class PropertyDefinition < ApplicationRecord
  # @todo PropertyDefinitions should not be Parentable. They are global and can be reused.
  include Parentable

  belongs_to :vocabulary, primary_key: :uuid
  parentable :vocabulary
  collection_options(
    display: :table
  )
  with_columns default: [
    NS.app[:predicate],
    NS.app[:propertyType],
    NS.ontola[:actionsMenu],
  ]

  validates :property_type, presence: true
  validates :predicate, presence: true

  enum property_type: {
    boolean_type: 0,
    string_type: 1,
    text_type: 2,
    datetime_type: 3,
    integer_type: 4,
    iri_type: 5,
    reference_type: 6
  }

  class << self
    def attributes_for_new(opts)
      {
        vocabulary: opts[:parent]
      }
    end
  end
end
