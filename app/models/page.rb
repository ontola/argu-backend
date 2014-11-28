class Page < ActiveRecord::Base
  extend FriendlyId

  belongs_to :profile, dependent: :destroy
  has_one :forum

  friendly_id :web_url, use: [:slugged, :finders]

  validates :name, :web_url, presence: true, length: {minimum: 3}
  validates :profile_id, presence: true
end
