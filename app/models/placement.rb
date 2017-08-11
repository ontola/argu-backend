# frozen_string_literal: true
class Placement < ApplicationRecord
  include DelegatedAttributes

  belongs_to :forum
  belongs_to :place
  belongs_to :placeable, polymorphic: true
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'
  before_validation :destruct_if_unneeded
  validate :validate_place, unless: :destroyed?

  enum placement_type: {home: 0, country: 1, custom: 2}
  delegated_attribute :country_code, :string, to: :place
  delegated_attribute :lat, :string, to: :place
  delegated_attribute :lon, :string, to: :place
  delegated_attribute :postal_code, :string, to: :place
  delegated_attribute :zoom_level, :integer, to: :place, default: 13

  # Returns a {Placement} in a #path
  # Sorted first ascending on the order of the #title given in #sort
  # and second descending on the position in the ltree
  # @param [String] :path The path the placement should be placed in
  # @param [Array<String>] :sort The order to sort the titles in
  # @return [Placement, nil] {Placement} or nil if no placement is found in the path
  def self.find_by_path(path, sort)
    return if path.nil?
    joins('INNER JOIN edges ON placements.placeable_id = edges.id AND placements.placeable_type = \'Edge\'')
      .where(placeable_id: path.split('.'))
      .select('*, nlevel(edges.path) AS nlevel')
      .select { |placement| sort.index(placement.placement_type).present? }
      .sort_by { |placement| [sort.index(placement.placement_type), -placement.nlevel] }
      .first
  end

  private

  # Destroys placement when no country_code and no postal_code is provided
  def destruct_if_unneeded
    destroy unless location_attributes.present?
  end

  def location_attributes
    Hash[
      %i(country_code lat lon postal_code)
        .map { |attr| [attr, send(attr)] }
        .select { |_k, v| v.present? }
    ]
  end

  def location_attributes_changed?
    %i(country_code lat lon postal_code).any? { |attr| send("#{attr}_changed?") }
  end

  # Validate whether the postal_code and country_code values are allowed and whether they match a {Place}
  # Will fail when a postal_code is provided, while the country_code is blank
  # or when {#Place.find_or_fetch_by} returns nil
  def validate_place
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
end
