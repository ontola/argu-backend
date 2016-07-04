class Page < ActiveRecord::Base
  include ArguBase, Edgeable, Shortnameable, Flowable

  has_one :profile, dependent: :destroy, as: :profileable, inverse_of: :profileable
  accepts_nested_attributes_for :profile
  belongs_to :owner, class_name: 'Profile', inverse_of: :pages
  has_many :forums, dependent: :restrict_with_exception, inverse_of: :page
  has_many :memberships, class_name: 'PageMembership', dependent: :destroy
  has_many :members, through: :memberships, source: :profile
  has_many :managerships, -> { where(role: PageMembership.roles[:manager]) }, class_name: 'PageMembership'
  has_many :managers, through: :managerships, source: :profile

  attr_accessor :repeat_name, :tab, :active

  delegate :description, to: :profile

  validates :shortname, presence: true, length: {minimum: 3, maximum: 50}
  validates :profile, :owner_id, :last_accepted, presence: true

  enum visibility: {open: 1, closed: 2, hidden: 3} #unrestricted: 0,

  def build_profile(*options)
    super(*options) if profile.nil?
  end

  def display_name
    if profile.present?
      profile.name || url
    else
      url
    end
  end

  # Since we're the ones creating activities, we should select them based on us being the owner
  def flow
    Activity.where(owner: profile)
  end

  def finished_intro?
    true
  end

  def email
    'anonymous'
  end

  def publisher
    owner.profileable
  end

  def root_object?
    true
  end

  def transfer_to!(repeat_url, new_profile)
    if url.present? && url == repeat_url && new_profile.present? && !new_profile.new_record?
      self.owner = new_profile
      save!
    end
  end
end
