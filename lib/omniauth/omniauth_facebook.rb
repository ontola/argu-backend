# frozen_string_literal: true
module Omniauth
  class OmniauthFacebook
    def self.create_user_without_shortname(auth, identity, r = nil)
      info = auth['info']
      raw = auth['extra']['raw_info']
      user = nil
      Identity.transaction do
        image_url = get_image_unless_silhouette(info['image'])
        name_arr = auth.info.name.split(' ')
        first_name = name_arr[0]
        middle_name = name_arr[1..-2].join(' ') if name_arr.length > 2
        last_name = name_arr[-1] if name_arr.length > 1
        user = User.new(
          email: auth.info.email,
          first_name: first_name,
          middle_name: middle_name,
          last_name: last_name,
          gender: raw['gender'],
          finished_intro: true,
          r: r,
          profile_attributes: {
            default_profile_photo_attributes: {
              remote_content_url: image_url
            }
          }
        )
        user.identities << identity
        user.shortname = nil
        user.primary_email_record.confirmed_at = DateTime.current
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
        image_url.query = 'redirect=false'

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
  end
end
