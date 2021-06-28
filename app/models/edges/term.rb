# frozen_string_literal: true

class Term < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Menuable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Tableable
  enhance CoverPhotoable
  enhance Attachable

  property :display_name, :string, NS.schema.name
  property :description, :text, NS.schema.text
  with_columns default: [
    NS.schema.name,
    NS.ontola[:updateAction],
    NS.ontola[:destroyAction]
  ]
  has_many :taggings,
           primary_key_property: nil,
           class_name: 'Edge',
           dependent: false
  with_collection :taggings,
                  association_class: Edge,
                  default_title: ->(r) { r.tagged_label || I18n.t('terms.tagged_items') },
                  default_display: :grid,
                  parent_uri_template: :taggings_collection_iri

  parentable :vocabulary

  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}

  delegate :tagged_label, to: :parent
end
