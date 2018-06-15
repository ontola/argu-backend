# frozen_string_literal: true

class Page < Edge
  has_many :groups, dependent: :destroy, inverse_of: :page, primary_key: :uuid
  has_many :discussions, through: :forum_edges

  enhance BlogPostable
  enhance CoverPhotoable
  enhance Createable
  enhance Destroyable
  enhance Discussable
  enhance Placeable
  enhance Updateable

  include Menuable

  has_one :profile, dependent: :destroy, as: :profileable, inverse_of: :profileable, primary_key: :uuid
  accepts_nested_attributes_for :profile
  has_many :profile_vote_matches, through: :profile, source: :vote_matches

  attr_accessor :confirmation_string, :tab, :active

  delegate :description, :default_profile_photo, to: :profile

  validates :url, presence: true, length: {minimum: 3, maximum: 50}
  validates :profile, :last_accepted, presence: true
  validates :base_color, css_hex_color: true

  after_create :create_default_groups
  after_create :create_staff_grant

  with_collection :vote_matches,
                  association: :profile_vote_matches,
                  pagination: true
  with_collection :forums, pagination: true

  parentable
  property :visibility, :integer, NS::ARGU[:visibility], default: 1, enum: {open: 1, closed: 2, hidden: 3}
  property :last_accepted, :datetime, NS::ARGU[:lastAccepted]
  property :base_color, :string, NS::ARGU[:baseColor]

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

  def root_object?
    true
  end

  def self.shortnameable?
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
    group.grants << Grant.new(grant_set: GrantSet.administrator, edge: self)
    group.save!

    service = CreateGroupMembership.new(
      group,
      attributes: {member: creator},
      options: {publisher: publisher, creator: creator}
    )
    service.on(:create_group_membership_failed) do |gm|
      raise gm.errors.full_messages.join('\n')
    end
    service.commit
  end

  def create_staff_grant
    staff_group = Group.find_by(id: Group::STAFF_ID)
    return if staff_group.nil?
    grant = Grant.new(grant_set: GrantSet.staff, edge: self, group: staff_group)
    grant.save!(validate: false)
  end
end
