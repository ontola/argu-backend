class Page < ActiveRecord::Base
  include ArguBase
  extend FriendlyId

  belongs_to :profile, dependent: :destroy
  accepts_nested_attributes_for :profile
  has_many :forums
  has_many :memberships, class_name: 'PageMembership'
  has_many :managers, -> { where(role: PageMembership.roles[:manager]) }, class_name: 'PageMembership'

  after_initialize :build_profile

  friendly_id :web_url, use: [:slugged, :finders]

  validates :web_url, presence: true, length: {minimum: 3}
  validates :profile, presence: true

  def build_profile(*options)
    if self.profile.nil?
      super(*options)
    end
  end

  def display_name
    if self.profile.present?
      self.profile.name || self.web_url
    else
     self.web_url
    end
  end

  def email

  end

  def username
    web_url
  end

end
