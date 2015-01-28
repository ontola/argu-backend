class AccessToken < ActiveRecord::Base
  belongs_to :item, polymorphic: true
  belongs_to :profile

  has_secure_token :access_token

end
