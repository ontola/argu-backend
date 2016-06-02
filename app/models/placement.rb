class Placement < ActiveRecord::Base
  include ArguBase

  belongs_to :forum
  belongs_to :place
  belongs_to :placeable, polymorphic: true
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'
  before_validation :destruct_if_unneeded
  validate :validate_place, unless: :destroyed?

  # @return [String] country_code from variable or from associated place
  def country_code
    @country_code || place.try(:country_code)
  end

  def country_code=(val)
    attribute_will_change!('country_code') unless val == country_code
    @country_code = val
  end

  # @return [String] postal_code from variable or from associated place
  def postal_code
    @postal_code || place.try(:postal_code)
  end

  def postal_code=(val)
    val.try(:upcase!).try(:delete!, ' ')
    attribute_will_change!('postal_code') unless val == postal_code
    @postal_code = val
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
      self.place = Place.find_or_fetch_by(postcode: postal_code, country_code: country_code)
      errors.add(:postal_code, I18n.t('placements.postal_with_county_not_found')) if place.nil?
    end
  end
end
