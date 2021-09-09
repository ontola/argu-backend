# frozen_string_literal: true

class Vocabulary < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Updatable
  enhance CoverPhotoable
  enhance Attachable
  enhance RootGrantable
  include Shortnameable

  property :display_name, :string, NS.schema.name
  property :description, :text, NS.schema.text
  property :tagged_label, :text, NS.argu[:taggedLabel]
  with_columns default: [
    NS.schema.name,
    NS.ontola[:updateAction],
    NS.ontola[:destroyAction]
  ]
  with_collection :terms, default_title: ->(r) { r.display_name }

  parentable :page

  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}
  validates :url, presence: true

  class << self
    def default_collection_display
      :table
    end

    def route_key
      :vocab
    end
  end
end
