# frozen_string_literal: true

class Term < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Menuable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Tableable
  enhance CoverPhotoable
  enhance Attachable

  property :display_name, :string, NS::SCHEMA[:name]
  property :description, :text, NS::SCHEMA[:text]
  with_columns default: [
    NS::SCHEMA[:name],
    NS::ONTOLA[:updateAction],
    NS::ONTOLA[:destroyAction]
  ]
  has_many :taggings,
           primary_key_property: nil,
           class_name: 'Edge',
           dependent: false
  with_collection :taggings,
                  association_class: Edge,
                  default_title: ->(r) { r.tagged_label || I18n.t('terms.tagged_items') },
                  parent_uri_template: :taggings_collection_iri,
                  parent_uri_template_canonical: :taggings_collection_canonical

  parentable :vocabulary

  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}

  delegate :tagged_label, to: :parent
end
