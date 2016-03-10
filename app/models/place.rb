class Place < ActiveRecord::Base
  has_many :placements
  has_many :placeables,
           through: :placements

  def country_code
    self.address['country_code'].try(:upcase)
  end

  def postal_code
    self.address['postcode']
  end

  def self.find_or_fetch_by(opts = {})
    scope = Place.all
    opts[:country_code] = opts[:country_code].downcase if opts[:country_code].present?
    opts.each do |key, value|
      if value.present?
        scope = scope.where("address->>'#{key}' = ?", value)
      else
        scope = scope.where("(address->'#{key}') is null")
      end
    end
    return scope.first if scope.present?
    Place.fetch url_for_osm_query(opts)
  end

  private

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

  def self.url_for_osm_query(params = {})
    params = {format: 'jsonv2', addressdetails: 1, limit: 1, polygon: 0, extratags: 1, namedetails: 1}.merge(params)
    params[:postalcode] = params.delete :postcode
    params[:country] = params.delete :country_code

    "https://nominatim.openstreetmap.org/search?#{params.to_query}"
  end
end
