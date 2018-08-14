# frozen_string_literal: true

class Page < Edge
  has_many :groups, -> { custom }, dependent: :destroy, inverse_of: :page, primary_key: :uuid

  enhance BlogPostable
  enhance ConfirmedDestroyable
  enhance CoverPhotoable
  enhance Createable
  enhance Discussable
  enhance Menuable
  enhance Placeable
  enhance Updateable
  enhance Actionable
  enhance Settingable

  has_many :discussions, through: :forums
  has_one :profile, dependent: :destroy, as: :profileable, inverse_of: :profileable, primary_key: :uuid
  accepts_nested_attributes_for :profile
  has_many :profile_vote_matches, through: :profile, source: :vote_matches

  scope :discover, lambda {
    joins(children: %i[properties grants])
      .where(grants: {group_id: Group::PUBLIC_ID}, properties: {predicate: NS::ARGU[:discoverable].to_s, boolean: true})
      .joins('LEFT JOIN (SELECT parent_id, SUM(follows_count) AS total_follows FROM edges GROUP BY parent_id) '\
             'AS forum_edges ON edges.id = forum_edges.parent_id')
      .order('forum_edges.total_follows DESC NULLS LAST')
  }

  delegate :description, :default_profile_photo, to: :profile

  validates :url, presence: true, length: {minimum: 3, maximum: 50}
  validates :profile, :last_accepted, presence: true
  validates :base_color, css_hex_color: true

  after_create :create_default_groups
  after_create :create_staff_grant

  with_collection :vote_matches,
                  association: :profile_vote_matches
  with_collection :forums
  with_collection :groups
  with_collection :shortnames

  parentable
  property :visibility, :integer, NS::ARGU[:visibility], default: 1, enum: {visible: 1, hidden: 3}
  property :last_accepted, :datetime, NS::ARGU[:lastAccepted]
  property :base_color, :string, NS::ARGU[:baseColor]

  def build_profile(*options)
    super(*options) if profile.nil?
  end

  def clear_children_iri_cache
    descendants.update_all(iri_cache: nil)
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

  def self.includes_for_serializer
    super.merge(profile: :default_profile_photo)
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

  def cache_iri!
    super
    clear_children_iri_cache
    iri_cache
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
