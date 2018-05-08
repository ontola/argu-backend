# frozen_string_literal: true

class Page < EdgeableBase
  has_many :groups, dependent: :destroy, inverse_of: :page
  has_many :forums, dependent: :restrict_with_exception, inverse_of: :page
  include Shortnameable
  include Menuable
  include Discussable

  has_one :profile, dependent: :destroy, as: :profileable, inverse_of: :profileable
  accepts_nested_attributes_for :profile
  belongs_to :owner, class_name: 'Profile', inverse_of: :pages
  has_many :profile_vote_matches, through: :profile, source: :vote_matches
  has_many :discussions, through: :forums

  attr_accessor :confirmation_string, :tab, :active

  delegate :description, to: :profile

  validates :shortname, presence: true, length: {minimum: 3, maximum: 50}
  validates :profile, :owner, :last_accepted, presence: true
  validates :base_color, css_hex_color: true

  after_create :create_default_groups
  after_create :create_staff_grant

  enum visibility: {open: 1, closed: 2, hidden: 3} # unrestricted: 0,

  with_collection :vote_matches,
                  association: :profile_vote_matches,
                  pagination: true
  with_collection :forums, pagination: true

  parentable

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

  def email
    'anonymous'
  end

  def iri_opts
    {id: url, root_id: url}
  end

  def publisher
    owner.profileable
  end

  def root_object?
    true
  end

  private

  def create_default_groups
    group = Group.new(
      name: 'Admins',
      name_singular: 'Admin',
      page: self,
      deletable: false
    )
    group.grants << Grant.new(grant_set: GrantSet.administrator, edge: edge)
    group.save!

    service = CreateGroupMembership.new(
      group,
      attributes: {member: owner},
      options: {publisher: owner.profileable, creator: owner}
    )
    service.on(:create_group_membership_failed) do |gm|
      raise gm.errors.full_messages.join('\n')
    end
    service.commit
  end

  def create_staff_grant
    staff_group = Group.find_by(id: Group::STAFF_ID)
    return if staff_group.nil?
    grant = Grant.new(grant_set: GrantSet.staff, edge: edge, group: staff_group)
    grant.save!(validate: false)
  end
end
