# Grants people access to resources when used.
#
# People can activate an `access_token` with argu.co?at=xxx
class AccessToken < ActiveRecord::Base
  belongs_to :item, polymorphic: true
  belongs_to :profile

  has_secure_token :access_token
end
