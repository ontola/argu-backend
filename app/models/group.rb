# frozen_string_literal: true

class Group < ApplicationRecord
  PUBLIC_ID = -1
  STAFF_ID = -2

  enhance ConfirmedDestroyable
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Createable
  enhance LinkedRails::Enhancements::Menuable
  enhance Settingable
  enhance LinkedRails::Enhancements::Updateable
  enhance LinkedRails::Enhancements::Tableable

  include Parentable
  include Edgeable::PropertyAssociations

  has_many :group_memberships, -> { active }
  has_many :unscoped_group_memberships, class_name: 'GroupMembership', dependent: :destroy
  has_many :grants, dependent: :destroy, inverse_of: :group
  has_many :members, through: :group_memberships, class_name: 'Profile'
  has_many :default_decision_forums,
           foreign_key_property: :default_decision_group_id,
           class_name: 'Forum',
           dependent: :restrict_with_exception
  belongs_to :page, required: true, inverse_of: :groups, primary_key: :uuid, foreign_key: :root_id
  has_many :decisions, foreign_key_property: :forwarded_group_id, dependent: :nullify
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

  def name_singular
    id == Group::PUBLIC_ID ? I18n.t('groups.public.name_singular') : super
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
  end
end
