# frozen_string_literal: true

class Term < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance Trashable
  enhance LinkedRails::Enhancements::Updatable
  enhance CoverPhotoable
  enhance Attachable
  enhance Orderable

  property :display_name, :string, NS.schema.name
  property :description, :text, NS.schema.text
  property :exact_match, :iri, NS.skos.exactMatch
  property :icon, :iri, NS.schema.image
  property :color, :string, NS.schema.color
  with_columns default: [
    NS.argu[:order],
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
                  display: :grid,
                  route_key: :taggings,
                  title: -> { parent.parent.tagged_label || I18n.t('terms.tagged_items') }

  parentable :vocabulary

  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}

  delegate :tagged_label, to: :parent

  def rdf_type
    parent.term_type.presence || super
  end

  class << self
    def from_iri(iri)
      term_id = fragment_from_iri(iri)

      find_by!(fragment: term_id) if term_id
    end

    def fragment_from_iri(iri)
      return false unless iri.to_s.starts_with?(LinkedRails.iri)

      match = iri_template.match(iri.to_s.split(LinkedRails.iri).last)

      match.captures.first if match.present?
    end
  end
end
