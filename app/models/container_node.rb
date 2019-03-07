# frozen_string_literal: true

class ContainerNode < Edge
  enhance ConfirmedDestroyable
  enhance CoverPhotoable
  enhance Createable
  enhance Exportable
  enhance Favorable
  enhance Feedable
  enhance Followable
  enhance Menuable
  enhance Moveable
  enhance Placeable
  enhance ProfilePhotoable
  enhance Updateable
  enhance Widgetable
  enhance Actionable
  enhance Statable

  property :display_name, :string, NS::SCHEMA[:name]
  property :bio, :text, NS::SCHEMA[:description]
  property :bio_long, :text, NS::SCHEMA[:text]
  property :cover_photo_attribution, :string, NS::ARGU[:photoAttribution]
  property :discoverable, :boolean, NS::ARGU[:discoverable], default: true
  property :locale, :string, NS::ARGU[:locale], default: 'nl-NL'

  with_collection :grants
  parentable :page

  after_save :reset_country
  after_save :reset_public_grant

  alias_attribute :description, :bio
  alias_attribute :name, :display_name
  alias_attribute :description, :bio

  auto_strip_attributes :name, :cover_photo_attribution, squish: true
  auto_strip_attributes :bio, nullify: false
  validates :url, presence: true, length: {minimum: 4, maximum: 75}
  validates :name, presence: true, length: {minimum: 4, maximum: 75}
  validates :bio, length: {maximum: 90}
  validates :bio_long, length: {maximum: 5000}

  attr_writer :public_grant

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

  def public_grant
    @public_grant ||= grants.find_by(group_id: Group::PUBLIC_ID)&.grant_set&.title&.to_sym || :none
  end

  private

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

  def reset_public_grant # rubocop:disable Metrics/AbcSize
    if public_grant&.to_sym == :none
      grants.where(group_id: Group::PUBLIC_ID).destroy_all
    else
      grants.joins(:grant_set).where('group_id = ? AND title != ?', Group::PUBLIC_ID, public_grant).destroy_all
      unless grants.joins(:grant_set).find_by(group_id: Group::PUBLIC_ID, grant_sets: {title: public_grant})
        grants.create!(group_id: Group::PUBLIC_ID, grant_set: GrantSet.find_by!(title: public_grant))
      end
    end
  end

  class << self
    def iri
      [super, NS::ARGU[:ContainerNode]]
    end

    def shortnameable?
      true
    end
  end
end

Dir["#{Rails.application.config.root}/app/models/container_nodes/*.rb"].each { |file| require_dependency file }
