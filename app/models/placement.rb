# frozen_string_literal: true

class Placement < ApplicationRecord
  include DelegatedAttributes
  include Parentable

  belongs_to :forum, primary_key: :uuid
  belongs_to :place, autosave: true
  belongs_to :placeable, polymorphic: true, primary_key: :uuid
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'
  before_save :update_zoom
  before_validation :destruct_if_unneeded
  validate :validate_place, unless: :marked_for_destruction?

  enum placement_type: {home: 0, country: 1, custom: 2}
  delegated_attribute :country_code, :string, to: :place
  delegated_attribute :lat, :decimal, to: :place
  delegated_attribute :lon, :decimal, to: :place
  delegated_attribute :postal_code, :string, to: :place
  delegated_attribute :zoom_level, :integer, to: :place, default: 13
  alias_attribute :display_name, :title
  alias parent placeable
  attr_writer :coordinates

  parentable :user, :edge

  # Returns a {Placement} in a #path
  # Sorted first ascending on the order of the #title given in #sort
  # and second descending on the position in the ltree
  # @param [String] :path The path the placement should be placed in
  # @param [Array<String>] :sort The order to sort the titles in
  # @return [Placement, nil] {Placement} or nil if no placement is found in the path
  def self.find_by_path(path, sort) # rubocop:disable Metrics/AbcSize
    return if path.nil?

    edge_uuids = Edge.where(id: path.split('.')).pluck(:uuid)
    joins('INNER JOIN edges ON placements.placeable_id = edges.uuid AND placements.placeable_type = \'Edge\'')
      .where(placeable_id: edge_uuids)
      .select('*, nlevel(edges.path) AS nlevel')
      .select { |placement| sort.index(placement.placement_type).present? }
      .min_by { |placement| [sort.index(placement.placement_type), -placement.nlevel] }
  end

  def coordinates
    [lat, lon]
  end

  private

  # Destroys placement when no country_code and no postal_code is provided
  def destruct_if_unneeded
    mark_for_destruction if location_attributes.blank?
  end

  def location_attributes
    Hash[
      %i[country_code lat lon postal_code]
        .map { |attr| [attr, send(attr)] }
        .select { |_k, v| v.present? }
    ]
  end

  def location_attributes_changed?
    %i[country_code lat lon postal_code].any? { |attr| send("#{attr}_changed?") }
  end

  def update_zoom
    place.zoom_level = zoom_level if place && zoom_level.present?
  end

  # Validate whether the postal_code and country_code values are allowed and whether they match a {Place}
  # Will fail when a postal_code is provided, while the country_code is blank
  # or when {#Place.find_or_fetch_by} returns nil
  def validate_place # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    if country_code.blank? && postal_code.present?
      errors.add(:country_code, I18n.t('placements.blank_country'))
    else
      if location_attributes_changed?
        self.place = Place.find_or_fetch_by(location_attributes) do |place|
          place.zoom_level = zoom_level if place && zoom_level.present?
        end
      end
      errors.add(:postal_code, I18n.t('placements.postal_with_county_not_found')) if place.nil?
    end
  end

  class << self
    # Hands over publication of a collection to the Community profile
    def anonymize(collection)
      collection.update_all(creator_id: Profile::COMMUNITY_ID) # rubocop:disable Rails/SkipsModelValidations
    end

    def attributes_for_new(opts)
      super.merge(placeable: opts[:parent])
    end

    def collection_from_parent_name(_parent, _params)
      :children_placement_collection
    end

    # Hands over ownership of a collection to the Community user
    def expropriate(collection)
      collection.update_all(publisher_id: User::COMMUNITY_ID) # rubocop:disable Rails/SkipsModelValidations
    end

    def default_per_page
      100
    end

    def preview_includes
      super + [:place]
    end
  end
end
