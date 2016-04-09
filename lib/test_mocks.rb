module TestMocks
  def facebook_auth_hash(opts = {})
    OmniAuth::AuthHash.new(
      provider: 'facebook',
      uid: opts[:uid] || '111907595807605',
      credentials: {
        token: opts[:token] || 'CAAKvnjt9N54BACAJ6Uj5LFywuhmo5vy2VUyvBqtZAPrZAUH10sy4KgxZAU0mZConMqV9ZB6kO4eZCC3Y822NbZCXdBjZAjUE9ubUscZBZB5WGHn32jIn2NU7UZAVYbAYWcmfg0vutOLZAw3LDs8YE2O5k2Nwde7zzMK1hyBrZC30wvIFnbjoaGegXEZBbL1fyJjGTUBLADCOczzZAHkDhH3mYqJp2y2'
      },
      info: {
        email: opts[:email] || 'testuser@example.com',
        first_name: opts[:first_name] || 'First',
        last_name: opts[:last_name] || 'Last'
      },
      extra: {
        raw_info: {
          middle_name: opts[:middle_name] || 'Middle'
        }
      })
  end

  def nominatim_netherlands
    stub_request(:get, 'https://nominatim.openstreetmap.org/search?addressdetails=1&country=nl&extratags=1&format=jsonv2&limit=1&namedetails=1&polygon=0&postalcode=')
      .to_return(body: [
        {
          place_id: "144005013",
          licence: "Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright",
          osm_type: "relation",
          osm_id: "2323309",
          boundingbox: [
            '11.777',
            '53.7253321',
            '-70.2695875',
            '7.2274985'
          ],
          lat: "52.5001698",
          lon: "5.7480821",
          display_name: "The Netherlands",
          place_rank: "4",
          category: "boundary",
          type: "administrative",
          importance: 0.4612931222686,
          icon: "https://nominatim.openstreetmap.org/images/mapicons/poi_boundary_administrative.p.20.png",
          address: {
            country: "The Netherlands",
            country_code: "nl"
          },
          extratags: {
            place: "country",
            wikidata: "Q29999",
            wikipedia: "nl:Koninkrijk der Nederlanden",
            population: "16645313"
          },
          namedetails: {
            name: "Nederland",
            int_name: "Nederland"
          }
        }
      ].to_json)
  end

  def nominatim_country_code_only
    stub_request(:get, 'https://nominatim.openstreetmap.org/search?addressdetails=1&country=nl&extratags=1&format=jsonv2&limit=1&namedetails=1&polygon=0&postalcode=')
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

  def nominatim_postal_code_valid
    stub_request(:get, 'https://nominatim.openstreetmap.org/search?addressdetails=1&country=nl&extratags=1&format=jsonv2&limit=1&namedetails=1&polygon=0&postalcode=3583GP')
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
    stub_request(:get, 'https://nominatim.openstreetmap.org/search?addressdetails=1&country=nl&extratags=1&format=jsonv2&limit=1&namedetails=1&polygon=0&postalcode=WRONG_POSTAL_CODE')
      .to_return(body: [].to_json)
  end
end
