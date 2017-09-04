# frozen_string_literal: true

# Grants people access to resources when used.
#
# People can activate an `access_token` with argu.co?at=xxx
# @todo Drop access_token table and remove this model
class AccessToken < ApplicationRecord
  belongs_to :item, polymorphic: true
  belongs_to :profile

  has_secure_token :access_token
end
