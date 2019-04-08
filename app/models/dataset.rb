# frozen_string_literal: true

class Dataset < Edge
  enhance Actionable
  enhance Commentable
  enhance Createable
  enhance Destroyable
  enhance Distributable
  enhance Updateable
  enhance Menuable


  property :identifier, :string, NS::DC[:identifier]
  property :description, :text, NS::DC[:description]
  property :display_name, :string, NS::DC[:title]
  property :language, :iri, NS::DC[:language]
  property :modified, :datetime, NS::DC[:modified]
  property :contact_point, :iri, NS::DCAT[:contactPoint] # vCard:Kind class
  # properties :keyword, :string, NS::DCAT[:keyword]
  property :published_by, :iri, NS::DC[:publisher] # donl:Organisatie
  property :theme, :iri, NS::DCAT[:theme]
  # properties :theme, :iri, NS::DCAT[:theme] # donl:TaxonomieBeleidsagenda
  property :landing_page, :iri, NS::DCAT[:landingPage]
  property :spatial, :iri, NS::DC[:spatial] # donl:Organisatie
  property :temporal, :iri, NS::DC[:temporal] # dct:PeriodOfTime class
  property :authority, :iri, NS::OVERHEID[:authority] # donl:Organisatie
  property :access_rights, :integer, NS::DC[:accessRights], enum: {open: 1, restricted: 2, non_public: 3}
  property :conforms_to, :iri, NS::DC[:conformsTo] # dct:Standard class
  property :page, :iri, NS::FOAF[:page]
  property :accrual_periodicity, :iri, NS::DC[:accrualPeriodicity]
  property :is_version_of_id, :linked_edge_id, NS::DC[:isVersionOf]
  property :provenance, :iri, NS::DC[:provenance] # dct:ProvenanceStatement class
  # properties :relation, :iri, NS::DC[:relation]
  property :issued, :datetime, NS::DC[:issued]
  property :source_id, :linked_edge_id, NS::DC[:source]
  # property :type, :iri, NS::DC[:type]
  property :version_info, :text, NS::OWL[:versionInfo]
  property :version_notes, :text, NS::ADMS[:versionNotes]
  # property :grondslag, :linked_edge_id, NS::OVERHEID[:grondslag]
  # property :doel, :string, NS::OVERHEIDDS[:doel]
  # property :kwaliteit, :string, NS::OVERHEIDDS[:kwaliteit]
  # property :LODStars, :string, NS::OVERHEIDDS[:LODStars]

  belongs_to :is_version_of, class_name: 'Dataset', foreign_key_property: :is_version_of_id
  belongs_to :source, class_name: 'Dataset', foreign_key_property: :source_id
  has_many :versions, class_name: 'Dataset', foreign_key_property: :is_version_of_id
  has_many :samples, class_name: 'Distribution', foreign_key_property: :sample_of_id

  parentable :data_catalog

  class << self
    def iri
      NS::DCAT[:Dataset]
    end
  end
end
