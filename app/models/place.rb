class Place < ActiveRecord::Base
  has_many :placements
  has_many :placeables,
           through: :placements

  def self.find_or_fetch(postal_code, country_code)
    place = Place.where("address->>'postcode' = ?", postal_code.upcase)
    return place.first if place.present?
    Place.fetch url(postal_code, country_code)
  end

  def self.fetch(url)
    result = JSON.parse(open(url).read).first
    return nil if result.nil?
    place = Place.create(
        id: result['place_id'],
        licence: result['licence'],
        osm_type: result['osm_type'],
        osm_id: result['osm_id'],
        boundingbox: result['boundingbox'],
        lat: result['lat'],
        lon: result['lon'],
        display_name: result['display_name'],
        osm_category: result['category'],
        osm_class: result['type'],
        osm_importance: result['importance'],
        icon: result['icon'],
        address: result['address'],
        extratags: result['extratags'],
        namedetails: result['namedetails'],
    )
    return place
  rescue OpenURI::HTTPError => error
    raise StandardError.new(error_message(error))
  end

  private

  def self.url(postal_code, country_code)
    "https://nominatim.openstreetmap.org/search?postalcode=#{postal_code}&countrycodes=#{country_code}&format=jsonv2&addressdetails=1&limit=1&polygon=0&extratags=1&namedetails=1"
  end
end
