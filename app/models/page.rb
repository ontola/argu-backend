class Page < ActiveRecord::Base
  extend FriendlyId

  belongs_to :profile, dependent: :destroy
  has_one :forum

  friendly_id :web_url, use: [:slugged, :finders]
end
