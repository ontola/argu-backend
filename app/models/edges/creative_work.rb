# frozen_string_literal: true

class CreativeWork < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance Trashable

  property :display_name, :string, NS.schema.name
  property :description, :text, NS.schema.text
  property :url_path, :string, NS.schema.url
  property :creative_work_type,
           :integer,
           NS.argu[:CreativeWorkType],
           default: 0,
           enum: {custom: 0}

  parentable :page, :container_node
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}

  def link_url
    LinkedRails.iri(path: url_path) if url_path
  end

  class << self
    def iri
      NS.schema.CreativeWork
    end
  end
end
