# frozen_string_literal: true

class Offer < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance Buyable
  collection_options(
    display: :grid
  )

  parentable :budget_shop

  delegate :display_name, :description, :default_cover_photo, to: :product, allow_nil: true

  class << self
    def iri
      NS.schema.Offer
    end

    def sort_options(collection)
      return super if collection.type == :infinite

      [NS.argu[:price], NS.schema.dateCreated]
    end
  end
end
