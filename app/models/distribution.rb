# frozen_string_literal: true

class Distribution < Edge
  enhance Createable
  enhance Commentable
  property :access_url, :iri, NS::DCAT[:accessURL]
  property :description, :text, NS::DC[:description]
  property :format, :iri, NS::DC[:format]
  property :license, :iri, NS::DC[:license]
  property :byte_size, :integer, NS::DCAT[:byteSize]
  # property :checksum, :string, NS::SPDX[:checksum] # spdx:Checksum class
  property :page, :iri, NS::FOAF[:page]
  property :download_url, :iri, NS::DCAT[:downloadURL]
  property :language, :iri, NS::DC[:language]
  property :conforms_to, :string, NS::DC[:conformsTo]
  property :media_type, :string, NS::DCAT[:mediaType]
  property :issued, :datetime, NS::DC[:issued]
  property :rights, :text, NS::DC[:rights]
  property :status, :iri, NS::ADMS[:status] # ADMS Status vocabulary
  property :display_name, :string, NS::DC[:title]
  property :modified, :datetime, NS::DC[:modified]

  property :sample_of_id, :string, NS::ARGU[:sampleOf]

  parentable :dataset

  class << self
    def iri
      NS::DCAT[:Distribution]
    end
  end
end
