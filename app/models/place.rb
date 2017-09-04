# frozen_string_literal: true

class Place < ApplicationRecord
  has_many :placements
  has_many :placeables,
           through: :placements
  DEFAULT_ZOOM_LEVEL = 13

  def country_code
    address.try(:[], 'country_code').try(:upcase)
  end

  def postal_code
    address.try(:[], 'postcode')
  end

  class << self
    # Find {Place} by provided opts. If {Place} is not found, try to {#fetch} from OSM
    # @param [Hash] opts the options to find a {Place}.
    # @option opts [String] :postal_code
    # @option opts [String] :country_code
    # @option opts [String] :lat
    # @option opts [String] :lon
    # @example Place.find_or_fetch_by(postcode: "3583GP", country_code: "nl")
    # @raise [StandardError] when a HTTP error occurs
    # @return [Place, nil] {Place} or nil if it couldn't be found in OSM
    def find_or_fetch_by(opts = {}, &block)
      opts[:country_code] = opts[:country_code].downcase if opts[:country_code].present?
      opts[:postcode] = opts.delete(:postal_code)&.upcase&.delete(' ')
      find_by_opts(opts) || create_or_fetch(opts, &block)
    end

    def find_or_fetch_country(country_code)
      find_or_fetch_by(country_code: country_code, postal_code: nil, street: nil, city: nil, town: nil, state: nil)
    end

    private

    def create_or_fetch(opts)
      place =
        if opts[:country_code].present? || opts[:postcode].present?
          fetch(url_for_osm_query(opts))
        else
          new(opts.slice(:lat, :lon))
        end
      yield place if block_given?
      place&.save!
      place
    end

    # Find {Place} by provided opts.
    # @param [Hash] opts the options to find a {Place}.
    # @option opts [String] :postcode
    # @option opts [String] :country_code
    # @example Place.find_or_fetch_by(postcode: "3583GP", country_code: "nl")
    # @return [Place, nil] {Place} or nil if it doesn't exist yet
    def find_by_opts(opts = {})
      return if opts[:lat] || opts[:lon]
      scope = all
      opts.each do |key, value|
        scope = if value.present?
                  scope.where('address->>? = ?', key, value)
                else
                  scope.where('(address->?) is null', key)
                end
      end
      scope.first
    end

    # Fetches Nominatim data from OSM and saves it as a {Place}
    # @return [Place, nil] {Place} or nil if it couldn't be found in OSM
    def fetch(url)
      result = JSON.parse(HTTParty.get(url).body).first
      return nil if result.nil?
      return find_by(nominatim_id: result['place_id']) if exists?(nominatim_id: result['place_id'])
      new(
        nominatim_id: result['place_id'],
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
        zoom_level: (result['importance'].to_f * 10 + 3).round || DEFAULT_ZOOM_LEVEL
      )
    rescue OpenURI::HTTPError => error
      raise StandardError.new(error_message(error))
    end

    # Converts the provided params to an OSM url to fetch a {Place}
    # @params [Hash] params
    # Will convert :postcode to :postalcode and :country_code to :country
    # @example Place.find_or_fetch_by(postcode: "3583GP", country_code: "nl")
    # @return [String] OSM url with params
    def url_for_osm_query(params = {})
      params = {format: 'jsonv2', addressdetails: 1, limit: 1, polygon: 0, extratags: 1, namedetails: 1}.merge(params)
      params[:postalcode] = params.delete :postcode
      params[:country] = params.delete :country_code

      "https://nominatim.openstreetmap.org/search?#{params.to_query}"
    end
  end
end
