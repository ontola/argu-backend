# frozen_string_literal: true

class Page < Edge # rubocop:disable Metrics/ClassLength
  ARGU_URL = 'argu'

  has_many :groups, -> { custom }, dependent: :destroy, inverse_of: :page, primary_key: :uuid, foreign_key: :root_id

  enhance Attachable
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
  enhance ProfilePhotoable
  enhance CoverPhotoable
  enhance Bannerable

  property :primary_container_node_id, :linked_edge_id, NS::FOAF[:homepage]
  has_many :discussions, through: :forums
  has_one :profile, dependent: :destroy, as: :profileable, inverse_of: :profileable, primary_key: :uuid
  has_one :tenant, dependent: :destroy, foreign_key: :root_id, primary_key: :uuid, inverse_of: :page
  has_many :descendant_shortnames,
           -> { where(primary: false) },
           class_name: 'Shortname',
           inverse_of: :root,
           foreign_key: :root_id,
           primary_key: :uuid

  delegate :database_schema, to: :tenant, allow_nil: true

  validates :url, presence: true, length: {minimum: 3, maximum: 50}
  validates :profile, :last_accepted, :iri_prefix, presence: true
  validates :name, presence: true, length: {minimum: 3, maximum: 75}

  after_create :tenant_create
  after_update :tenant_update
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
  with_collection :intervention_types
  with_collection :vocabularies

  parentable :user
  placeable :custom
  property :display_name, :string, NS::SCHEMA[:name]
  property :last_accepted, :datetime, NS::ARGU[:lastAccepted]
  property :locale, :string, NS::ARGU[:locale], default: 'nl-NL'
  property :template, :string, NS::ONTOLA[:template], default: :default
  property :template_options, :text, NS::ONTOLA[:templateOpts], default: '{}'
  property :home_menu_label, :string, NS::ONTOLA[:homeMenuLabel]
  property :home_menu_image, :string, NS::ONTOLA[:homeMenuImage]
  property :requires_intro, :boolean, NS::ONTOLA[:requiresIntro], default: false
  property :matomo_site_id, :string, NS::ONTOLA[:matomoSiteId]
  property :matomo_host, :string, NS::ONTOLA[:matomoHost]
  property :allowed_external_sources, :string, NS::ONTOLA[:allowedExternalSources], array: true
  property :enable_white_label, :boolean, NS::ONTOLA[:enableWhiteLabel]
  property :styled_headers, :boolean, NS::ONTOLA[:styledHeaders]
  property :live_updates, :boolean, NS::ONTOLA[:liveUpdates], default: false

  belongs_to :primary_container_node,
             foreign_key_property: :primary_container_node_id,
             class_name: 'Edge',
             dependent: false

  def accepted_terms
    last_accepted.present?
  end

  def accepted_terms=(bool)
    self.last_accepted = bool.to_s == 'true' ? Time.current : nil
  end

  def all_shortnames
    @all_shortnames = shortnames.pluck(:shortname)
  end

  def build_profile(*options)
    super(*options) if profile.nil?
  end

  def display_name
    super || url
  end

  def email
    'anonymous'
  end

  def home_menu_image
    return default_profile_photo&.iri if super.nil?

    RDF::URI(super) if super.present?
  end

  def home_menu_label
    super || display_name
  end

  def include_resources
    [primary_container_node&.iri].compact
  end

  def iri(_opts = {})
    return anonymous_iri if iri_prefix.blank?

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

  def reindex_tree(async: {wait: true})
    return if Rails.application.config.disable_searchkick

    ActsAsTenant.with_tenant(self) { Edge.reindex(async: async) }
    ActsAsTenant.with_tenant(self) { Group.reindex(async: async) }
  end

  def root_object?
    true
  end

  def set_template_option(key, value)
    opts = JSON.parse(template_options)
    opts[key] = value
    self.template_options = opts.to_json
  end

  # Not sure why, but sometimes tenant is nil while it exists in the db
  def tenant
    super || Tenant.find_by(root_id: root_id)
  end

  def url=(value)
    if iri_prefix.blank? || iri_prefix.starts_with?(Rails.application.config.host_name)
      @iri_prefix = "#{Rails.application.config.host_name}/#{value}"
      @iri = nil
    end
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

  def create_default_groups # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
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

  def tenant_update
    tenant.update!(iri_prefix: iri_prefix)
  end

  def tenant_create
    create_tenant!(root_id: uuid, iri_prefix: iri_prefix, database_schema: Apartment::Tenant.current)
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
      find_via_shortname(ARGU_URL)
    end

    def menu_class
      AppMenuList
    end

    def preview_includes
      super + %i[default_profile_photo] - %w[navigations_menu settings_menu]
    end

    def update_iris(from, to, scope = nil) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      escaped_from = ApplicationRecord.connection.quote_string(from)
      escaped_to = ApplicationRecord.connection.quote_string(to)
      # rubocop:disable Rails/SkipsModelValidations
      Widget
        .where(scope)
        .update_all("resource_iri = replace(resource_iri::text, '#{escaped_from}', '#{escaped_to}')::text[]")
      Property
        .where(predicate: [NS::SCHEMA.url.to_s, NS::ONTOLA[:templateOpts].to_s])
        .where(scope)
        .update_all("text = replace(text, '#{escaped_from}', '#{escaped_to}')")
      CustomMenuItem
        .where(scope)
        .update_all("href = replace(href, '#{escaped_from}', '#{escaped_to}')")
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
