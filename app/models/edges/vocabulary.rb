# frozen_string_literal: true

class Vocabulary < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Menuable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Tableable
  enhance CoverPhotoable
  enhance Attachable
  enhance RootGrantable
  include Shortnameable

  property :display_name, :string, NS::SCHEMA[:name]
  property :description, :text, NS::SCHEMA[:text]
  property :tagged_label, :text, NS::ARGU[:taggedLabel]
  with_columns default: [
    NS::SCHEMA[:name],
    NS::ONTOLA[:updateAction],
    NS::ONTOLA[:destroyAction]
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
  end
end
