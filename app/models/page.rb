class Page < ActiveRecord::Base
  extend FriendlyId

  belongs_to :profile, dependent: :destroy
  accepts_nested_attributes_for :profile
  has_one :forum

  after_initialize :build_profile

  friendly_id :web_url, use: [:slugged, :finders]

  validates :web_url, presence: true, length: {minimum: 3}
  validates :profile, presence: true

  def build_profile(*options)
    if self.profile.nil?
      super(*options)
    end
  end

end
