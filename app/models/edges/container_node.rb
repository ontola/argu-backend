# frozen_string_literal: true

class ContainerNode < Edge
  include DeltaHelper

  enhance ConfirmedDestroyable
  enhance CoverPhotoable
  enhance Exportable
  enhance Feedable
  enhance Followable
  enhance Placeable
  enhance ChildrenPlaceable
  enhance RootGrantable
  enhance LinkedRails::Enhancements::Updatable
  enhance Widgetable
  enhance Statable
  enhance CreativeWorkable
  enhance CustomActionable
  enhance Surveyable
  enhance Projectable
  enhance BudgetShoppable
  enhance RootGrantable

  property :display_name, :string, NS.schema.name
  property :bio, :text, NS.schema.description
  property :bio_long, :text, NS.schema.text
  property :cover_photo_attribution, :string, NS.argu[:photoAttribution]
  property :discoverable, :boolean, NS.argu[:discoverable], default: true
  property :show_header, :boolean, NS.argu[:showHeader], default: true

  collection_options(
    display: :settingsTable,
    route_key: :container_nodes
  )
  with_columns settings: [
    NS.schema.name,
    RDF.type,
    NS.argu[:grantedGroups],
    NS.argu[:followsCount],
    NS.ontola[:updateAction],
    NS.ontola[:destroyAction]
  ]

  parentable :page, :phase

  alias_attribute :description, :bio
  alias_attribute :name, :display_name
  alias_attribute :description, :bio

  attr_writer :create_menu_item

  auto_strip_attributes :name, :cover_photo_attribution, squish: true
  auto_strip_attributes :bio, nullify: false
  validates :url, presence: true, length: {minimum: 4, maximum: 75}
  validates :display_name, presence: true, length: {minimum: 4, maximum: 75}
  validates :bio, length: {maximum: 5_000}
  validates :bio_long, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}

  def self.inherited(klass)
    klass.enhance LinkedRails::Enhancements::Creatable
    klass.collection_options(
      route_key: klass.route_key.to_sym
    )

    super
  end

  def added_delta
    [
      invalidate_resource_delta(parent.menu(:navigations))
    ]
  end

  def hide_header
    !show_header
  end

  def iri_template_name
    :container_nodes_iri
  end

  private

  def create_menu_item?
    return @create_menu_item unless @create_menu_item.nil?

    true
  end

  class << self
    def action_dialog(collection)
      RDF::URI("#{collection.parent.collection_iri(:container_nodes)}/actions") if self == ContainerNode
    end

    def iri
      [super, NS.argu[:ContainerNode]]
    end

    def route_key
      return '' if self == ContainerNode

      super
    end
  end
end

Dir["#{Rails.application.config.root}/app/models/container_nodes/*.rb"].each { |file| require_dependency file }
