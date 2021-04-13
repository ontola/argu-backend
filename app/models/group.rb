# frozen_string_literal: true

class Group < ApplicationRecord
  PUBLIC_ID = -1
  STAFF_ID = -2

  enhance ConfirmedDestroyable
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Indexable
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Menuable
  enhance Settingable
  enhance Searchable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Tableable

  include Parentable
  include Edgeable::PropertyAssociations

  has_many :group_memberships, -> { active }, inverse_of: :group
  has_many :unscoped_group_memberships, class_name: 'GroupMembership', dependent: :destroy
  has_many :grants, dependent: :destroy, inverse_of: :group
  has_many :members, through: :group_memberships, class_name: 'Profile'
  has_many :default_decision_forums,
           primary_key: :id,
           primary_key_property: :default_decision_group_id,
           class_name: 'Forum',
           dependent: :restrict_with_exception
  belongs_to :page, optional: false, inverse_of: :groups, primary_key: :uuid, foreign_key: :root_id
  has_many :decisions, primary_key_property: :forwarded_group_id, dependent: :nullify
  accepts_nested_attributes_for :grants, reject_if: :all_blank
  alias_attribute :display_name, :name

  with_collection :grants
  with_collection :group_memberships
  with_columns settings: [
    NS::SCHEMA[:name],
    NS::ORG[:hasMember],
    NS::ONTOLA[:settingsMenu],
    NS::ONTOLA[:destroyAction]
  ]

  validates :name, presence: true, length: {minimum: 3, maximum: 75}, uniqueness: {scope: :root_id}
  validates :name_singular, presence: true, length: {minimum: 3, maximum: 75}, uniqueness: {scope: :root_id}

  scope :custom, -> { where('groups.id > 0') }

  delegate :publisher, to: :page
  delegate :include?, to: :members

  parentable :page
  alias edgeable_record parent

  def action_triples
    return super if id.positive? || ActsAsTenant.current_tenant.url == Page::ARGU_URL

    []
  end

  def as_json(options = {})
    super(options.merge(except: %i[created_at updated_at]))
  end

  def display_name
    id == Group::PUBLIC_ID ? I18n.t('groups.public.name') : name
  end

  def inherited_grants(edge)
    grants
      .joins(:edge)
      .where(edges: {id: edge.self_and_ancestor_ids})
  end

  def iri(opts = {})
    return @iri if @iri && opts.empty?

    iri ||= ActsAsTenant.with_tenant(page || ActsAsTenant.current_tenant) { super }
    @iri = iri if opts.empty?
    iri
  end

  def name_singular
    id == Group::PUBLIC_ID ? I18n.t('groups.public.name_singular') : super
  end

  def searchable_should_index?
    root_id == ActsAsTenant.current_tenant.root_id || id <= 0
  end

  class << self
    def iri
      [super, NS::ORG['Organization']]
    end

    def public
      Group.find_by(id: Group::PUBLIC_ID)
    end

    def root_collection_opts
      super.merge(parent: ActsAsTenant.current_tenant)
    end

    def staff
      Group.find_by(id: Group::STAFF_ID)
    end

    def show_includes
      [:organization]
    end

    def sort_options(_collection)
      [NS::SCHEMA[:name], NS::SCHEMA[:dateCreated]]
    end
  end
end
