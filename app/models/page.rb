# frozen_string_literal: true

class Page < Edge # rubocop:disable Metrics/ClassLength
  has_many :groups, -> { custom }, dependent: :destroy, inverse_of: :page, primary_key: :uuid, foreign_key: :root_id

  enhance BlogPostable
  enhance ConfirmedDestroyable
  enhance CoverPhotoable
  enhance Createable
  enhance Discussable
  enhance Exportable
  enhance Feedable
  enhance Menuable
  enhance Placeable
  enhance Updateable
  enhance Actionable
  enhance Settingable
  enhance Statable
  enhance Widgetable

  has_many :discussions, through: :forums
  has_one :profile, dependent: :destroy, as: :profileable, inverse_of: :profileable, primary_key: :uuid
  accepts_nested_attributes_for :profile, update_only: true
  has_many :descendant_shortnames,
           -> { where(primary: false) },
           class_name: 'Shortname',
           foreign_key: :root_id,
           primary_key: :uuid

  scope :discover, lambda {
    joins(children: %i[properties grants])
      .where(grants: {group_id: Group::PUBLIC_ID}, properties: {predicate: NS::ARGU[:discoverable].to_s, boolean: true})
      .order(follows_count: :desc)
  }

  delegate :description, :default_profile_photo, to: :profile

  validates :url, presence: true, length: {minimum: 3, maximum: 50}
  validates :profile, :last_accepted, presence: true
  validates :base_color, css_hex_color: true

  after_create :create_default_groups
  after_create :create_staff_grant

  with_collection :forums
  with_collection :groups
  with_collection :shortnames, association: :descendant_shortnames

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

  def iri_opts
    {id: url, root_id: url}
  end

  def iri_path(opts = {})
    ActsAsTenant.current_tenant == self ? '' : super
  end

  def root_object?
    true
  end

  def cache_iri_path!
    super
    clear_children_iri_cache
    iri_cache
  end

  private

  def create_default_groups # rubocop:disable Metrics/AbcSize
    group = Group.new(
      name: 'Admins',
      name_singular: 'Admin',
      page: self,
      deletable: false
    )
    group.grants << Grant.new(grant_set: GrantSet.administrator, edge: self)
    group.save!
    return if creator.reserved?

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

  class << self
    def preview_includes
      super + %i[default_profile_photo]
    end

    def shortnameable?
      true
    end
  end
end
