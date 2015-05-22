module Omniauth
  class OmniauthFacebook
    def self.create_user_without_shortname(auth, identity)
      info = auth['info']
      raw = auth['extra']['raw_info']
      user = nil
      Identity.transaction do
        user = User.new email: info['email'],
                 first_name: info['first_name'],
                 middle_name: raw['middle_name'],
                 last_name: info['last_name'],
                 gender: raw['gender']
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
  end
end
