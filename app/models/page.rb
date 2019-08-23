# frozen_string_literal: true

class Page < Edge # rubocop:disable Metrics/ClassLength
  has_many :groups, -> { custom }, dependent: :destroy, inverse_of: :page, primary_key: :uuid, foreign_key: :root_id

  enhance BlogPostable
  enhance ConfirmedDestroyable
  enhance CoverPhotoable
  enhance LinkedRails::Enhancements::Createable
  enhance Discussable
  enhance Exportable
  enhance Feedable
  enhance LinkedRails::Enhancements::Menuable
  enhance Placeable
  enhance LinkedRails::Enhancements::Updateable
  enhance Settingable
  enhance Statable
  enhance Stylable
  enhance Widgetable

  has_many :discussions, through: :forums
  has_one :profile, dependent: :destroy, as: :profileable, inverse_of: :profileable, primary_key: :uuid
  accepts_nested_attributes_for :profile, update_only: true
  has_one :tenant, dependent: :destroy, foreign_key: :root_id, primary_key: :uuid, inverse_of: :page
  has_many :descendant_shortnames,
           -> { where(primary: false) },
           class_name: 'Shortname',
           foreign_key: :root_id,
           primary_key: :uuid

  scope :discover, lambda {
    joins(children: %i[properties grants])
      .where(grants: {group_id: Group::PUBLIC_ID}, properties: {predicate: NS::ARGU[:discoverable].to_s, boolean: true})
      .order(follows_count: :desc)
      .distinct
  }

  delegate :description, :default_profile_photo, to: :profile
  delegate :database_schema, to: :tenant, allow_nil: true

  validates :url, presence: true, length: {minimum: 3, maximum: 50}
  validates :profile, :last_accepted, :iri_prefix, presence: true

  after_create :create_or_update_tenant
  after_create :create_default_groups
  after_create :create_staff_grant
  after_create :reindex

  attr_writer :iri_prefix

  with_collection :container_nodes
  with_collection :blogs
  with_collection :forums
  with_collection :open_data_portals
  with_collection :groups
  with_collection :shortnames, association: :descendant_shortnames
  with_collection :risks
  with_collection :intervention_types

  parentable :user
  placeable :custom
  property :visibility, :integer, NS::ARGU[:visibility], default: 1, enum: {visible: 1, hidden: 3}
  property :last_accepted, :datetime, NS::ARGU[:lastAccepted]
  property :use_new_frontend, :boolean, NS::ARGU[:useNewFrontend], default: false
  property :primary_container_node_id, :linked_edge_id, NS::FOAF[:homepage]
  belongs_to :primary_container_node,
             foreign_key_property: :primary_container_node_id,
             class_name: 'ContainerNode',
             dependent: false

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

  def iri(_opts = {})
    @iri ||=
      if RequestStore.store[:old_frontend]
        super
      else
        RDF::URI("#{Rails.env.test? ? :http : :https}://#{iri_prefix}")
      end
  end

  def iri_prefix
    @iri_prefix || tenant&.iri_prefix
  end

  def reindex_tree(async: true)
    ActsAsTenant.with_tenant(self) { Edge.reindex(async: async) }
  end

  def root_object?
    true
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

  def create_or_update_tenant
    Tenant.find_or_create_by!(root_id: uuid) do |t|
      t.iri_prefix = iri_prefix
      t.database_schema = Apartment::Tenant.current
    end
  end

  def create_staff_grant
    staff_group = Group.find_by(id: Group::STAFF_ID)
    return if staff_group.nil?
    grant = Grant.new(grant_set: GrantSet.staff, edge: self, group: staff_group)
    grant.save!(validate: false)
  end

  class << self
    def argu
      find_via_shortname('argu')
    end

    def preview_includes
      super + %i[default_profile_photo] - %w[navigations_menu settings_men]
    end
  end
end
