# frozen_string_literal: true

module Argu
  module TestHelpers
    module TestMocks
      def create_email_mock(template, email, **options) # rubocop:disable Metrics/MethodLength
        email_only = options.delete(:email_only)
        tenant = options.delete(:tenant) || :argu
        recipient =
          email_only ? {email: email, language: /.+/} : {display_name: /.+/, id: /.+/, language: /.+/, email: email}
        stub_request(:post, expand_service_url(:email, "/#{tenant}/email/spi/emails"))
          .with(
            body: {
              email: {
                template: template,
                recipient: recipient,
                options: options.presence
              }.compact
            }
          )
      end

      def mapbox_mock
        stub_request(
          :post,
          "https://api.mapbox.com/tokens/v2/#{ENV['MAPBOX_USERNAME']}?access_token=#{ENV['MAPBOX_KEY']}"
        ).to_return(status: 200, body: {token: 'token'}.to_json)
      end

      def nominatim_netherlands # rubocop:disable Metrics/MethodLength
        stub_request(:get,
                     'http://open.mapquestapi.com/nominatim/v1/search?addressdetails=1&country=nl&'\
                     'extratags=1&format=json&limit=1&namedetails=1&polygon=0&postalcode=&state=&street=&town=&city=')
          .to_return(body: [
            {
              place_id: '144005013',
              licence: 'Data © OpenStreetMap contributors, ODbL 1.0. '\
                       'http://www.openstreetmap.org/copyright',
              osm_type: 'relation',
              osm_id: '2323309',
              boundingbox: %w[
                11.777
                53.7253321
                -70.2695875
                7.2274985
              ],
              lat: '52.5001698',
              lon: '5.7480821',
              display_name: 'The Netherlands',
              place_rank: '4',
              category: 'boundary',
              type: 'administrative',
              importance: 0.4612931222686,
              icon: 'https://nominatim.openstreetmap.org/images/mapicons/poi_boundary_administra'\
                    'tive.p.20.png',
              address: {
                country: 'The Netherlands',
                country_code: 'nl'
              },
              extratags: {
                place: 'country',
                wikidata: 'Q29999',
                wikipedia: 'nl:Koninkrijk der Nederlanden',
                population: '16645313'
              },
              namedetails: {
                name: 'Nederland',
                int_name: 'Nederland'
              }
            }
          ].to_json)
      end

      def nominatim_country_code_only # rubocop:disable Metrics/MethodLength
        stub_request(:get,
                     'http://open.mapquestapi.com/nominatim/v1/search?addressdetails=1&country=nl&'\
                     'extratags=1&format=json&limit=1&namedetails=1&polygon=0&postalcode=')
          .to_return(body: [
            {
              place_id: '144005013',
              address: {
                country: 'Koninkrijk der Nederlanden',
                country_code: 'nl'
              }
            }
          ].to_json)
      end

      def nominatim_postal_code_valid # rubocop:disable Metrics/MethodLength
        stub_request(:get,
                     'http://open.mapquestapi.com/nominatim/v1/search?addressdetails=1&country=nl&'\
                     'extratags=1&format=json&limit=1&namedetails=1&polygon=0&postalcode=3583GP')
          .to_return(body: [
            {
              place_id: '145555300',
              address: {
                suburb: 'Utrecht',
                city: 'Utrecht',
                county: 'Bestuur Regio Utrecht',
                state: 'Utrecht',
                postcode: '3583GP',
                country: 'Koninkrijk der Nederlanden',
                country_code: 'nl'
              }
            }
          ].to_json)
      end

      def nominatim_postal_code_wrong
        stub_request(:get,
                     'http://open.mapquestapi.com/nominatim/v1/search?addressdetails=1&country=nl&'\
                     'extratags=1&format=json&limit=1&namedetails=1&polygon=0&postalcode='\
                     'WRONG_POSTAL_CODE')
          .to_return(body: [].to_json)
      end

      def validate_valid_bearer_token(root: :argu)
        stub_request(:get,
                     Addressable::Template.new("#{service_url(:token)}/#{root}/tokens/verify{?jwt}"))
          .to_return(status: 200)
      end

      def validate_invalid_bearer_token(root: :argu)
        stub_request(:get,
                     Addressable::Template.new("#{service_url(:token)}/#{root}/tokens/verify{?jwt}"))
          .to_return(status: 404)
      end
    end
  end
end
