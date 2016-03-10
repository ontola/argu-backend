class Placement < ActiveRecord::Base
  belongs_to :forum
  belongs_to :place
  belongs_to :placeable, polymorphic: true
  belongs_to :creator, class_name: 'Profile'
  before_validation :destruct_if_unneeded
  validate :validate_place, unless: :destroyed?

  def country_code
    @country_code || self.place.try(:country_code)
  end

  def country_code=(val)
    attribute_will_change!('country_code') unless val == country_code
    @country_code = val
  end

  def postal_code
    @postal_code || self.place.try(:postal_code)
  end

  def postal_code=(val)
    val.try(:upcase!).try(:delete!, ' ')
    attribute_will_change!('postal_code') unless val == postal_code
    @postal_code = val
  end

  private

  def destruct_if_unneeded
    if country_code.blank? && postal_code.blank?
      self.destroy
    end
  end

  def validate_place
    if country_code.blank? && postal_code.present?
      errors.add(:country_code, I18n.t('placements.blank_country'))
    else
      self.place = Place.find_or_fetch_by(postcode: postal_code, country_code: country_code)
      errors.add(:postal_code, I18n.t('placements.postal_with_county_not_found')) if self.place.nil?
    end
  end
end
