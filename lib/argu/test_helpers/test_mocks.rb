# frozen_string_literal: true

module Argu
  module TestHelpers
    module TestMocks
      def create_email_mock(template, email, options)
        email_only = options.delete(:email_only)
        recipient =
          email_only ? {email: email, language: /.+/} : {display_name: /.+/, id: /.+/, language: /.+/, email: email}
        stub_request(:post, expand_service_url(:email, '/argu/email/spi/emails'))
          .with(
            body: {
              email: {
                template: template,
                recipient: recipient,
                options: options
              }
            }
          )
      end

      def facebook_picture(opts = {})
        uid = opts[:uid] || '102555400181774'
        stub_request(:get, "https://graph.facebook.com/v2.8/#{uid}/picture?redirect=false&type=large")
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
            image: opts[:image] || "https://graph.facebook.com/v2.8/#{uid}/picture?type=large"
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

      def facebook_me(token: nil, fields: {email: 'bpvjlwt_zuckersen_1467905538@tfbnw.net'})
        token ||= 'EAANZAZBdAOGgUBADbu25EDEen6EXgLfTFGN28R6G9E0vgDQEsLuFEMDBNe7v7jUpRCmb4SmS'\
                  'Qqcam37vnKszs80z28WBdJEiBHnHmZCwr3Fv33v1w5jvGZBE6ACZCZBmqkTewz65Deckyyf9b'\
                  'r4Nsxz5dSZAQBJ8uqtFEEEj01ncwZDZD'
        params = {
          access_token: token,
          fields: fields.keys.join(',')
        }
        if ENV['FACEBOOK_SECRET']
          params[:appsecret_proof] =
            OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), ENV['FACEBOOK_SECRET'], token)
        end
        stub_request(
          :get,
          "https://graph.facebook.com/me?#{params.to_param}"
        )
          .to_return(
            status: 200,
            body: {id: '102555400181774'}.merge(fields).to_json
          )
      end

      def mapbox_mock
        stub_request(
          :post,
          "https://api.mapbox.com/tokens/v2/#{ENV['MAPBOX_USERNAME']}?access_token=#{ENV['MAPBOX_KEY']}"
        ).to_return(status: 200, body: {token: 'token'}.to_json)
      end

      def nominatim_netherlands
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

      def nominatim_country_code_only
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

      def nominatim_postal_code_valid
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

      def validate_valid_bearer_token
        stub_request(:get,
                     Addressable::Template.new("#{service_url(:token)}/tokens/verify{?jwt}"))
          .to_return(status: 200)
      end

      def validate_invalid_bearer_token
        stub_request(:get,
                     Addressable::Template.new("#{service_url(:token)}/tokens/verify{?jwt}"))
          .to_return(status: 404)
      end
    end
  end
end
