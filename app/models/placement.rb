# frozen_string_literal: true
class Placement < ApplicationRecord
  belongs_to :forum
  belongs_to :place
  belongs_to :placeable, polymorphic: true
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'
  before_validation :destruct_if_unneeded
  validate :validate_place, unless: :destroyed?

  enum placement_type: {home: 0, country: 1}

  attribute :country_code, :string
  attribute :postal_code, :string

  # delegate these attributes to place when the attribute is not set
  %i(country_code postal_code).each do |attr|
    define_method attr do
      attributes[attr.to_s] || place&.send(attr)
    end
  end

  private

  # Destroys placement when no country_code and no postal_code is provided
  def destruct_if_unneeded
    destroy if country_code.blank? && postal_code.blank?
  end

  # Validate whether the postal_code and country_code values are allowed and whether they match a {Place}
  # Will fail when a postal_code is provided, while the country_code is blank
  # or when {#Place.find_or_fetch_by} returns nil
  def validate_place
    if country_code.blank? && postal_code.present?
      errors.add(:country_code, I18n.t('placements.blank_country'))
    else
      self.place = Place.find_or_fetch_by(postal_code: postal_code, country_code: country_code)
      errors.add(:postal_code, I18n.t('placements.postal_with_county_not_found')) if place.nil?
    end
  end
end
