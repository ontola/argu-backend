# frozen_string_literal: true

class Offer < Edge
  enhance LinkedRails::Enhancements::Indexable
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance Buyable

  parentable :budget_shop

  delegate :display_name, :description, :default_cover_photo, to: :product, allow_nil: true

  belongs_to :product, foreign_key_property: :product_id, class_name: 'Edge', dependent: false

  class << self
    def default_collection_display
      :grid
    end

    def iri
      NS::SCHEMA.Offer
    end

    def sort_options(collection)
      return super if collection.type == :infinite

      [NS::ARGU[:price], NS::SCHEMA.dateCreated]
    end
  end
end
