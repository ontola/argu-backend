# frozen_string_literal: true

class Page < Edge # rubocop:disable Metrics/ClassLength
  has_many :groups, -> { custom }, dependent: :destroy, inverse_of: :page, primary_key: :uuid, foreign_key: :root_id

  enhance BlogPostable
  enhance ConfirmedDestroyable
  enhance CoverPhotoable
  enhance LinkedRails::Enhancements::Creatable
  enhance Discussable
  enhance Exportable
  enhance Feedable
  enhance LinkedRails::Enhancements::Menuable
  enhance Placeable
  enhance LinkedRails::Enhancements::Updatable
  enhance Settingable
  enhance Statable
  enhance Stylable
  enhance CreativeWorkable

  has_many :discussions, through: :forums
  has_one :profile, dependent: :destroy, as: :profileable, inverse_of: :profileable, primary_key: :uuid
  accepts_nested_attributes_for :profile, update_only: true
  has_one :tenant, dependent: :destroy, foreign_key: :root_id, primary_key: :uuid, inverse_of: :page
  has_many :descendant_shortnames,
           -> { where(primary: false) },
           class_name: 'Shortname',
           inverse_of: :root,
           foreign_key: :root_id,
           primary_key: :uuid

  scope :discover, lambda {
    joins(children: %i[properties grants])
      .where(grants: {group_id: Group::PUBLIC_ID}, properties: {predicate: NS::ARGU[:discoverable].to_s, boolean: true})
      .order(follows_count: :desc)
      .distinct
  }

  delegate :about, :description, :default_profile_photo, to: :profile
  delegate :database_schema, to: :tenant, allow_nil: true

  validates :url, presence: true, length: {minimum: 3, maximum: 50}
  validates :profile, :last_accepted, :iri_prefix, presence: true

  after_save :create_or_update_tenant
  after_create :create_default_groups
  after_create :create_staff_grant
  after_create :create_activity_menu_item
  after_create -> { reindex_tree(async: false) }
  after_update :update_primary_node_menu_item, if: :primary_container_node_id_previously_changed?

  attr_writer :iri_prefix

  with_collection :container_nodes
  with_collection :custom_menu_items, association: :navigations_menu_items, association_class: CustomMenuItem
  with_collection :blogs
  with_collection :forums
  with_collection :open_data_portals
  with_collection :groups
  with_collection :shortnames, association: :descendant_shortnames
  with_collection :risks
  with_collection :intervention_types
  with_collection :measure_types

  parentable :user
  placeable :custom
  property :last_accepted, :datetime, NS::ARGU[:lastAccepted]
  property :locale, :string, NS::ARGU[:locale], default: 'nl-NL'
  property :primary_container_node_id, :linked_edge_id, NS::FOAF[:homepage]
  property :template, :string, NS::ONTOLA[:template], default: :default
  property :template_options, :text, NS::ONTOLA[:templateOpts], default: '{}'
  property :home_menu_label, :string, NS::ONTOLA[:homeMenuLabel]
  property :home_menu_image, :string, NS::ONTOLA[:homeMenuImage]
  property :requires_intro, :boolean, NS::ONTOLA[:requiresIntro], default: false
  property :matomo_site_id, :string, NS::ONTOLA[:matomoSiteId]
  property :allowed_external_sources, :string, NS::ONTOLA[:allowedExternalSources], array: true

  belongs_to :primary_container_node,
             foreign_key_property: :primary_container_node_id,
             class_name: 'Edge',
             dependent: false
  validates :about, length: {maximum: 3000}

  def build_profile(*options)
    super(*options) if profile.nil?
  end

  def about=(value)
    build_profile
    profile.about = value
  end

  def display_name=(value)
    build_profile
    profile.name = value
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

  def home_menu_image
    return default_profile_photo.iri if super.nil?

    RDF::URI(super) if super.present?
  end

  def home_menu_label
    super || display_name
  end

  def include_resources
    [primary_container_node&.iri].compact
  end

  def iri(_opts = {})
    @iri ||= RDF::URI("#{Rails.env.test? ? :http : :https}://#{iri_prefix}")
  end

  def iri_prefix
    @iri_prefix || tenant&.iri_prefix
  end

  def language
    locale.split('-').first.to_sym
  end

  def manifest
    @manifest ||= Manifest.new(page: self)
  end

  def rebuild_cache
    ActsAsTenant.with_tenant(self) do
      cache = Argu::Cache.new
      Vocabulary.new.write_to_cache(cache)

      Edge.descendants.each do |klass|
        Edge.where(owner_type: klass.to_s).includes(klass.includes_for_serializer).find_each do |edge|
          edge.write_to_cache(cache)
        end
      end
    end
  end

  def reindex_tree(async: {wait: true})
    return if Rails.application.config.disable_searchkick

    ActsAsTenant.with_tenant(self) { Edge.reindex(async: async) }
  end

  def root_object?
    true
  end

  # Not sure why, but sometimes tenant is nil while it exists in the db
  def tenant
    super || Tenant.find_by(root_id: root_id)
  end

  def write_to_cache(cache = Argu::Cache.new)
    manifest.write_to_cache(cache)
    SearchResult.new(parent: self).write_to_cache(cache)
    super
  end

  private

  def create_activity_menu_item
    CustomMenuItem.navigations.create(
      href: feeds_iri(self),
      label: 'menus.default.activity',
      label_translation: true,
      order: 100,
      resource: self
    )
  end

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
    return tenant.update!(iri_prefix: iri_prefix) if tenant.present?

    create_tenant(root_id: uuid, iri_prefix: iri_prefix, database_schema: Apartment::Tenant.current)
  end

  def create_staff_grant
    staff_group = Group.find_by(id: Group::STAFF_ID)
    return if staff_group.nil?

    grant = Grant.new(grant_set: GrantSet.staff, edge: self, group: staff_group)
    grant.save!(validate: false)
  end

  def update_primary_node_menu_item
    if previous_changes[:primary_container_node_id].first
      CustomMenuItem
        .navigations
        .find_or_create_by(resource: self, edge_id: previous_changes[:primary_container_node_id].first)
    end
    CustomMenuItem
      .navigations
      .find_by(resource: self, edge_id: previous_changes[:primary_container_node_id].second)
      &.destroy
    true
  end

  class << self
    def argu
      find_via_shortname('argu')
    end

    def preview_includes
      super + %i[default_profile_photo] - %w[navigations_menu settings_menu]
    end

    def update_iris(from, to, scope = nil)
      escaped_from = ApplicationRecord.connection.quote_string(from)
      escaped_to = ApplicationRecord.connection.quote_string(to)
      # rubocop:disable Rails/SkipsModelValidations
      Widget
        .where(scope)
        .update_all("resource_iri = replace(resource_iri::text, '#{escaped_from}', '#{escaped_to}')::text[]")
      Property
        .where(predicate: NS::SCHEMA.url.to_s)
        .where(scope)
        .update_all("text = replace(text, '#{escaped_from}', '#{escaped_to}')")
      CustomMenuItem
        .where(scope)
        .update_all("href = replace(href, '#{escaped_from}', '#{escaped_to}')")
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
