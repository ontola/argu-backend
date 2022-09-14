# frozen_string_literal: true

require 'vocab_syncer'

class Page < Edge # rubocop:disable Metrics/ClassLength
  ARGU_URL = 'argu'

  has_many :groups, dependent: :destroy, inverse_of: :root, primary_key: :uuid, foreign_key: :root_id
  has_one :users_group, -> { users }, class_name: 'Group', inverse_of: :root, primary_key: :uuid, foreign_key: :root_id
  has_one :admin_group, -> { admin }, class_name: 'Group', inverse_of: :root, primary_key: :uuid, foreign_key: :root_id

  enhance Attachable
  enhance BlogPostable
  enhance ConfirmedDestroyable
  enhance CoverPhotoable
  enhance LinkedRails::Enhancements::Creatable
  enhance Exportable
  enhance Feedable
  enhance Placeable
  enhance LinkedRails::Enhancements::Updatable
  enhance Settingable
  enhance Statable
  enhance Stylable
  enhance CreativeWorkable
  enhance ProfilePhotoable
  enhance CoverPhotoable
  enhance Bannerable

  property :primary_container_node_id, :linked_edge_id, NS.foaf[:homepage], association_class: 'Edge'
  has_one :profile, dependent: :destroy, as: :profileable, inverse_of: :profileable, primary_key: :uuid
  has_one :tenant, dependent: :destroy, foreign_key: :root_id, primary_key: :uuid, inverse_of: :page
  has_many :descendant_shortnames,
           -> { where(primary: false) },
           class_name: 'Shortname',
           inverse_of: :root,
           foreign_key: :root_id,
           primary_key: :uuid

  validates :url, presence: true, length: {minimum: 3, maximum: 50}
  validates :profile, :iri_prefix, :tier, presence: true
  validates :name, presence: true, length: {minimum: 3, maximum: 75}

  after_create -> { reindex_tree(async: false) }
  after_update :tenant_update
  after_update :update_language, if: :language_previously_changed?
  after_update :update_primary_node_menu_item, if: :primary_container_node_id_previously_changed?
  after_save :save_manifest
  include Bootstrap

  attr_writer :iri_prefix

  collection_options(
    include_members: true
  )

  with_collection :container_nodes
  with_collection :custom_forms
  with_collection :custom_menu_items, association: :navigations_menu_items, association_class: CustomMenuItem
  with_collection :blogs
  with_collection :forums
  with_collection :groups
  with_collection :shortnames, association: :descendant_shortnames
  with_collection :vocabularies

  parentable :user
  property :display_name, :string, NS.schema.name
  property :language, :string, NS.schema.Language, default: :nl
  property :tier, :integer, NS.argu[:tier], enum: {free: 0, basic: 1, standard: 2}, default: 0
  property :template, :string, NS.ontola[:template], default: :default
  property :template_options, :text, NS.ontola[:templateOpts], default: '{}'
  property :home_menu_label, :string, NS.ontola[:homeMenuLabel]
  property :home_menu_image, :string, NS.ontola[:homeMenuImage]
  property :requires_intro, :boolean, NS.ontola[:requiresIntro], default: false
  property :matomo_site_id, :string, NS.ontola[:matomoSiteId]
  property :matomo_host, :string, NS.ontola[:matomoHost]
  property :matomo_cdn, :string, NS.ontola[:matomoCdn]
  property :piwik_pro_site_id, :string, NS.ontola[:piwikProSiteId]
  property :piwik_pro_host, :string, NS.ontola[:piwikProHost]
  property :google_tag_manager, :string, NS.ontola[:googleTagManager]
  property :google_uac, :string, NS.ontola[:googleUac]
  property :allowed_external_sources, :string, NS.ontola[:allowedExternalSources], array: true
  property :hide_language_switcher, :boolean, NS.ontola[:hideLanguageSwitcher]
  property :styled_headers, :boolean, NS.ontola[:styledHeaders]

  def all_shortnames
    @all_shortnames ||=
      Shortname.joins(:owner).where(shortnames: {root_id: nil}, edges: {root_id: uuid}).pluck(:shortname)
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

  def feature_enabled?(feature)
    tier = Rails.application.config.tiers.fetch(feature)

    tier_before_type_cast >= tier
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

  def iri(**_opts)
    return anonymous_iri if iri_prefix.blank? || (ActsAsTenant.current_tenant && ActsAsTenant.current_tenant != self)

    @iri ||= RDF::URI(LinkedRails::URL.as_href("#{Rails.env.test? ? :http : :https}://#{iri_prefix}"))
  end

  def iri_prefix
    @iri_prefix || tenant&.iri_prefix
  end

  def join_user(user)
    return if user.nil? || user.profile.group_memberships.where(group: users_group).any?

    create_membership(users_group, user, user.profile)
  end

  def manifest
    @manifest ||= Manifest.new(page: self)
  end

  def reindex_tree(async: {wait: true})
    return if Rails.application.config.disable_searchkick
    return unless feature_enabled?(:search)

    ActsAsTenant.with_tenant(self) do
      Edge.reindex(async: async)
      Group.reindex(async: async)
      User.reindex(async: async)
    end
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

  def save_manifest
    manifest.save
  end

  def tenant_update
    tenant.update!(iri_prefix: iri_prefix)
  end

  def update_language
    I18n.locale = language

    ActsAsTenant.with_tenant(self) do
      VocabSyncWorker.perform_async
    end
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

    def attributes_for_new(opts)
      attrs = super
      attrs[:language] ||= I18n.locale
      attrs
    end

    def build_new(parent: nil, user_context: nil)
      record = super
      record.build_profile
      record
    end

    def menu_class
      AppMenuList
    end

    def preview_includes
      super + %i[default_profile_photo]
    end

    def requested_single_resource(params, _user_context)
      return super if params.key?(:id)

      ActsAsTenant.current_tenant
    end

    def route_key
      :o
    end

    def update_iris(from, to, scope = nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      Manifest.move("#{LinkedRails.scheme}://#{from}", "#{LinkedRails.scheme}://#{to}")

      escaped_from = ApplicationRecord.connection.quote_string(from)
      escaped_to = ApplicationRecord.connection.quote_string(to)

      # rubocop:disable Rails/SkipsModelValidations
      Widget
        .where(scope)
        .update_all("resource_iri = replace(resource_iri::text, '#{escaped_from}', '#{escaped_to}')::text[]")
      Property
        .where(predicate: [NS.schema.url.to_s, NS.ontola[:templateOpts]])
        .where(scope)
        .update_all("text = replace(text, '#{escaped_from}', '#{escaped_to}')")
      CustomMenuItem
        .where(scope)
        .update_all("href = replace(href, '#{escaped_from}', '#{escaped_to}')")
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
