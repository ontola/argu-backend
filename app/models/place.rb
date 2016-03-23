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

  # Find {Place} by provided opts. If {Place} is not found, try to {#fetch} from OSM
  # @param [Hash] opts the options to find a {Place}.
  # @option opts [String] :postcode
  # @option opts [String] :country_code
  # @example Place.find_or_fetch_by(postcode: "3583GP", country_code: "nl")
  # @raise [StandardError] when a HTTP error occurs
  # @return [Place, nil] {Place} or nil if it couldn't be found in OSM
  def self.find_or_fetch_by(opts = {})
    scope = Place.all
    opts[:country_code] = opts[:country_code].downcase if opts[:country_code].present?
    opts[:postcode] = opts[:postcode].upcase.delete(' ') if opts[:postcode].present?
    opts.each do |key, value|
      if value.present?
        scope = scope.where("address->>? = ?", key, value)
      else
        scope = scope.where("(address->?) is null", key)
      end
    end
    return scope.first if scope.present?
    Place.fetch url_for_osm_query(opts)
  end

  private

  # Fetches Nominatim data from OSM and saves it as a {Place}
  # @return [Place, nil] {Place} or nil if it couldn't be found in OSM
  def self.fetch(url)
    result = JSON.parse(HTTParty.get(url).body).first
    return nil if result.nil?
    return Place.find(result['place_id']) if Place.exists?(result['place_id'])
    Place.create(
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
  rescue OpenURI::HTTPError => error
    raise StandardError.new(error_message(error))
  end

  # Converts the provided params to an OSM url to fetch a {Place}
  # @params [Hash] params
  # Will convert :postcode to :postalcode and :country_code to :country
  # @example Place.find_or_fetch_by(postcode: "3583GP", country_code: "nl")
  # @return [String] OSM url with params
  def self.url_for_osm_query(params = {})
    params = {format: 'jsonv2', addressdetails: 1, limit: 1, polygon: 0, extratags: 1, namedetails: 1}.merge(params)
    params[:postalcode] = params.delete :postcode
    params[:country] = params.delete :country_code

    "https://nominatim.openstreetmap.org/search?#{params.to_query}"
  end
end
