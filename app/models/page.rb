class Page < ActiveRecord::Base
  include ArguBase
  extend FriendlyId

  belongs_to :profile, dependent: :destroy
  belongs_to :owner, class_name: 'Profile', inverse_of: :pages
  accepts_nested_attributes_for :profile
  has_many :forums
  has_many :groups, through: :group_memberships
  has_many :memberships, class_name: 'PageMembership', dependent: :destroy
  has_many :managers, -> { where(role: PageMembership.roles[:manager]) }, class_name: 'PageMembership'

  after_initialize :build_profile

  friendly_id :web_url, use: [:slugged, :finders]

  attr_accessor :repeat_name

  validates :web_url, presence: true, length: {minimum: 3}
  validates :profile, :owner_id, presence: true

  enum visibility: {open: 1, closed: 2, hidden: 3} #unrestricted: 0,

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
    'anonymous'
  end

  def username
    web_url
  end

  def should_generate_new_friendly_id?
    web_url_changed?
  end

end
