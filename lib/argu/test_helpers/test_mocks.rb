# frozen_string_literal: true
module Argu
  module TestHelpers
    module TestMocks
      def analytics_collect
        stub_request(:post, 'https://ssl.google-analytics.com/collect')
          .to_return(status: 200)
      end

      def facebook_picture(opts = {})
        uid = opts[:uid] || '102555400181774'
        stub_request(:get, "https://graph.facebook.com/v2.6/#{uid}/picture?redirect=false")
          .to_return(
            status: 200,
            body: File.new(File.expand_path('./test/fixtures/fb_image_silhouette.jpg'))
          )
      end

      def facebook_auth_hash(opts = {})
        uid = opts[:uid] || '102555400181774'
        facebook_picture(opts)
        OmniAuth::AuthHash.new(
          provider: 'facebook',
          uid: uid,
          info: {
            email: opts[:email] || 'bpvjlwt_zuckersen_1467905538@tfbnw.net',
            name: opts[:name] || 'Rick Alabhaidbbdfg Zuckersen',
            image: opts[:image] || "https://graph.facebook.com/v2.6/#{uid}/picture?type=large"
          },
          credentials: {
            token: opts[:token] ||
              'EAANZAZBdAOGgUBADbu25EDEen6EXgLfTFGN28R6G9E0vgDQEsLuFEMDBNe7v7jUpRCmb4SmSQ'\
              'qcam37vnKszs80z28WBdJEiBHnHmZCwr3Fv33v1w5jvGZBE6ACZCZBmqkTewz65Deckyyf9br4'\
              'Nsxz5dSZAQBJ8uqtFEEEj01ncwZDZD',
            expires_at: 1_473_099_257,
            expires: true
          },
          extra: {
            raw_info: {
              name: opts[:name] || 'Rick Alabhaidbbdfg Zuckersen',
              email: opts[:email] || 'bpvjlwt_zuckersen_1467905538@tfbnw.net',
              id: uid
            }
          }
        )
      end

      def facebook_me(token)
        stub_request(
          :get,
          "https://graph.facebook.com/me?access_token=#{token}"
        )
          .to_return(
            status: 200,
            body: {
              id: '102555400181774',
              email: 'bpvjlwt_zuckersen_1467905538@tfbnw.net'
            }.to_json
          )
      end

      def nominatim_netherlands
        stub_request(:get,
                     'https://nominatim.openstreetmap.org/search?addressdetails=1&country=nl'\
                     '&extratags=1&format=jsonv2&limit=1&namedetails=1&polygon=0&postalcode=')
          .to_return(body: [
            {
              place_id: '144005013',
              licence: 'Data © OpenStreetMap contributors, ODbL 1.0. '\
                       'http://www.openstreetmap.org/copyright',
              osm_type: 'relation',
              osm_id: '2323309',
              boundingbox: %w(
                11.777
                53.7253321
                -70.2695875
                7.2274985
              ),
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

      def nominatim_country_code_only
        stub_request(:get,
                     'https://nominatim.openstreetmap.org/search?addressdetails=1&country=nl&'\
                     'extratags=1&format=jsonv2&limit=1&namedetails=1&polygon=0&postalcode=')
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
        stub_request(:get,
                     'https://nominatim.openstreetmap.org/search?addressdetails=1&country=nl&'\
                     'extratags=1&format=jsonv2&limit=1&namedetails=1&polygon=0&postalcode=3583GP')
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
                     'https://nominatim.openstreetmap.org/search?addressdetails=1&country=nl&'\
                     'extratags=1&format=jsonv2&limit=1&namedetails=1&polygon=0&postalcode='\
                     'WRONG_POSTAL_CODE')
          .to_return(body: [].to_json)
      end

      def linked_record_mock(id)
        stub_request(:get, "https://iri.test/resource/#{id}")
          .to_return(status: 200, body: {
            title: 'Record name'
          }.to_json)
      end
    end
  end
end
