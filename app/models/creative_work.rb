# frozen_string_literal: true

class CreativeWork < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Menuable
  enhance Trashable

  property :display_name, :string, NS::SCHEMA[:name]
  property :description, :text, NS::SCHEMA[:text]
  property :url_path, :string, NS::SCHEMA[:url]
  property :creative_work_type,
           :integer,
           NS::ARGU[:CreativeWorkType],
           default: 0,
           enum: {custom: 0}

  parentable :page, :container_node
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}

  def link_url
    RDF::DynamicURI(LinkedRails.iri(path: url_path)) if url_path
  end

  class << self
    def iri
      NS::SCHEMA[:CreativeWork]
    end
  end
end
