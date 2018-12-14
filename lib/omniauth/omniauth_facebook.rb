# frozen_string_literal: true

module Omniauth
  class OmniauthFacebook
    def self.create_user_without_shortname(auth, identity, r, language)
      user = nil
      Identity.transaction do
        user = new_user(auth, r, language)
        user.identities << identity
        user.shortname = nil
        user.primary_email_record.confirmed_at = Time.current
        identity.save!
        user.save!
      end
      user
    end

    def self.email_for(auth)
      auth['info']['email']
    end

    def self.get_image_unless_silhouette(image)
      image_url = nil
      begin
        image_url = URI.parse(image)
        image_url.query = 'redirect=false&type=large'

        response = Net::HTTP.get_response(image_url)
        if response.code == '200'
          json = JSON.parse(response.body)
          image_url = json['data']['url'] unless json['data']['is_silhouette']
        else
          image_url = nil
        end
      rescue URI::InvalidURIError, JSON::ParserError
        image_url = nil
      ensure
        image_url
      end
    end

    def self.new_user(auth, r, language) # rubocop:disable Metrics/AbcSize
      info = auth['info']
      raw = auth['extra']['raw_info']

      image_url = get_image_unless_silhouette(info['image'])
      name_arr = auth.info.name.split(' ')
      first_name = name_arr[0]
      middle_name = name_arr[1..-2].join(' ') if name_arr.length > 2
      last_name = name_arr[-1] if name_arr.length > 1

      User.new(
        email: auth.info.email,
        first_name: first_name,
        middle_name: middle_name,
        language: language,
        last_name: last_name,
        last_accepted: Time.current,
        gender: raw['gender'],
        r: r,
        profile_attributes: {
          default_profile_photo_attributes: {
            remote_content_url: image_url
          }
        }
      )
    end
  end
end
