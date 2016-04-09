module Omniauth
  class OmniauthFacebook
    def self.create_user_without_shortname(auth, identity, r = nil)
      info = auth['info']
      raw = auth['extra']['raw_info']
      user = nil
      Identity.transaction do
        image_url = get_image_unless_silhouette(info['image'])

        user =
          User.new email: info['email'],
                   first_name: info['first_name'],
                   middle_name: raw['middle_name'],
                   last_name: info['last_name'],
                   gender: raw['gender'],
                   finished_intro: true,
                   r: r,
                   profile_attributes: {
                     remote_profile_photo_url: image_url
                   }
        user.identities << identity
        user.shortname = nil
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
