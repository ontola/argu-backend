# frozen_string_literal: true

class ContainerNode < Edge
  enhance ConfirmedDestroyable
  enhance CoverPhotoable
  enhance Exportable
  enhance Favorable
  enhance Feedable
  enhance Followable
  enhance LinkedRails::Enhancements::Menuable
  enhance Moveable
  enhance Placeable
  enhance ChildrenPlaceable
  enhance ProfilePhotoable
  enhance PublicGrantable
  enhance LinkedRails::Enhancements::Updatable
  enhance Widgetable
  enhance Statable
  enhance LinkedRails::Enhancements::Tableable
  enhance CreativeWorkable
  enhance CustomActionable
  enhance Surveyable
  enhance Projectable

  property :display_name, :string, NS::SCHEMA[:name]
  property :bio, :text, NS::SCHEMA[:description]
  property :bio_long, :text, NS::SCHEMA[:text]
  property :cover_photo_attribution, :string, NS::ARGU[:photoAttribution]
  property :discoverable, :boolean, NS::ARGU[:discoverable], default: true
  property :locale, :string, NS::ARGU[:locale], default: 'nl-NL'
  property :show_header, :boolean, NS::ARGU[:showHeader], default: true

  with_collection :grants
  with_columns settings: [
    NS::SCHEMA[:name],
    NS::ARGU[:followsCount],
    NS::ONTOLA[:updateAction],
    NS::ONTOLA[:destroyAction]
  ]

  parentable :page
  placeable :country, :custom

  after_save :reset_country

  alias_attribute :description, :bio
  alias_attribute :name, :display_name
  alias_attribute :description, :bio

  accepts_nested_attributes_for :grants, reject_if: :all_blank, allow_destroy: true

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

  def enforce_hidden_last_name?
    url == 'youngbelegen'
  end

  def iri_opts
    {id: url}
  end

  def iri_template_name
    :container_nodes_iri
  end

  def language
    locale.split('-').first.to_sym
  end

  def move_to(_new_parent)
    super do
      grants.where('group_id != ?', Group::PUBLIC_ID).destroy_all
    end
  end

  private

  def create_menu_item?
    true
  end

  def reset_country # rubocop:disable Metrics/AbcSize
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
    def iri
      [super, NS::ARGU[:ContainerNode]]
    end
  end
end

Dir["#{Rails.application.config.root}/app/models/container_nodes/*.rb"].each { |file| require_dependency file }
