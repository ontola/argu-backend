# frozen_string_literal: true

class Group < ApplicationRecord
  enhance ConfirmedDestroyable
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance Settingable
  enhance Searchable

  include Cacheable
  include Parentable

  has_many :group_memberships, -> { active }, inverse_of: :group
  has_many :unscoped_group_memberships, class_name: 'GroupMembership', dependent: :destroy
  has_many :grants, dependent: :destroy, inverse_of: :group
  has_many :members, through: :group_memberships, class_name: 'Profile'
  accepts_nested_attributes_for :grants, reject_if: :all_blank
  alias_attribute :display_name, :name

  scope :confirmation_required, -> { where(require_confirmation: true) }

  enum group_type: {custom: 0, users: 1, admin: 2}

  collection_options(
    association: :groups,
    parent: -> { ActsAsTenant.current_tenant }
  )
  with_collection :grants
  with_collection :group_memberships,
                  title: lambda {
                    parent.users? ? I18n.t('users.plural') : I18n.t('argu.GroupMembership.plural_label')
                  }
  with_collection :search_results,
                  association_base: -> { SearchResult::Query.new(self) },
                  association_class: Group,
                  collection_class: SearchResult::Collection,
                  iri_template_keys: %i[q match],
                  route_key: :search

  with_columns settings: [
    NS.schema.name,
    NS.org[:hasMember],
    NS.ontola[:settingsMenu]
  ]
  filterable group_type: {}

  validates :name, presence: true, length: {minimum: 3, maximum: 75}, uniqueness: {scope: :root_id}
  validates :name_singular, presence: true, length: {minimum: 3, maximum: 75}, uniqueness: {scope: :root_id}

  delegate :publisher, to: :root
  delegate :include?, to: :members

  parentable :root
  acts_as_tenant :root, class_name: 'Edge', primary_key: :uuid

  alias parent root
  alias edgeable_record root

  def action_triples
    return super if id.positive? || ActsAsTenant.current_tenant.url == Page::ARGU_URL

    []
  end

  def as_json(options = {})
    super(options.merge(except: %i[created_at updated_at]))
  end

  def bearer_token_collection
    iri_from_template(
      :tokens_collection_iri,
      token_type: :bearer,
      group_id: id
    )
  end

  def email_token_collection
    iri_from_template(
      :tokens_collection_iri,
      token_type: :email,
      group_id: id
    )
  end

  def inherited_grants(edge)
    grants
      .joins(:edge)
      .where(edges: {id: edge.self_and_ancestor_ids})
  end

  def iri(**opts)
    return @iri if @iri && opts.empty?

    iri ||= ActsAsTenant.with_tenant(root || ActsAsTenant.current_tenant) { super }
    @iri = iri if opts.empty?
    iri
  end

  def searchable_should_index?
    root_id == ActsAsTenant.current_tenant.root_id || id <= 0
  end

  def show_includes
    [:organization]
  end

  class << self
    def attributes_for_new(opts)
      attrs = super
      attrs[:root] = ActsAsTenant.current_tenant
      attrs
    end

    def iri
      [super, NS.org['Organization']]
    end

    def route_key
      :g
    end

    def sort_options(_collection)
      [NS.schema.name, NS.schema.dateCreated]
    end
  end
end
