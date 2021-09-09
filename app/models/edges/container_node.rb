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
  enhance ProfilePhotoable
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
  property :locale, :string, NS.argu[:locale], default: 'nl-NL'
  property :show_header, :boolean, NS.argu[:showHeader], default: true

  with_columns settings: [
    NS.schema.name,
    NS.argu[:followsCount],
    NS.ontola[:updateAction],
    NS.ontola[:destroyAction]
  ]

  parentable :page
  placeable :country, :custom

  after_save :reset_country

  alias_attribute :description, :bio
  alias_attribute :name, :display_name
  alias_attribute :description, :bio

  auto_strip_attributes :name, :cover_photo_attribution, squish: true
  auto_strip_attributes :bio, nullify: false
  validates :url, presence: true, length: {minimum: 4, maximum: 75}
  validates :name, presence: true, length: {minimum: 4, maximum: 75}
  validates :bio, length: {maximum: 260}
  validates :bio_long, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}

  def self.inherited(klass)
    klass.enhance LinkedRails::Enhancements::Creatable
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

  def iri_opts
    {id: url}
  end

  def iri_template_name
    :container_nodes_iri
  end

  private

  def create_menu_item?
    true
  end

  def reset_country # rubocop:disable Metrics/MethodLength
    country_code = locale.split('-').second
    return if country_placement&.country_code == country_code

    place = Place.find_or_fetch_country(country_code)
    placement =
      placements
        .country
        .first_or_create do |p|
        p.creator = creator
        p.publisher = publisher
        p.place = place
      end
    placement.update!(place: place) unless placement.place == place
  end

  class << self
    def attributes_for_new(opts)
      attrs = super
      attrs[:locale] = ActsAsTenant.current_tenant.locale
      attrs
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
