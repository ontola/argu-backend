class Page < ActiveRecord::Base
  include ArguBase, Shortnameable

  has_one :profile, dependent: :destroy, as: :profileable
  belongs_to :owner, class_name: 'Profile', inverse_of: :pages
  accepts_nested_attributes_for :profile
  has_many :forums
  has_many :memberships, class_name: 'PageMembership', dependent: :destroy
  has_many :managers, -> { where(role: PageMembership.roles[:manager]) }, class_name: 'PageMembership'

  after_initialize :build_default_associations, if: :new_record?

  attr_accessor :repeat_name

  validates :shortname, presence: true, length: {minimum: 3, maximum: 50}
  validates :profile, :owner_id, presence: true

  enum visibility: {open: 1, closed: 2, hidden: 3} #unrestricted: 0,

  def build_profile(*options)
    if self.profile.nil?
      super(*options)
    end
  end

  def display_name
    if self.profile.present?
      self.profile.name || self.url
    else
     self.url
    end
  end

  def finished_intro?
    true
  end

  def email
    'anonymous'
  end

  def transfer_to!(repeat_url, new_profile)
    if self.url.present? && self.url == repeat_url && new_profile.present? && !new_profile.new_record?
      self.owner = new_profile
      save!
    end
  end

end
