# frozen_string_literal: true

class Grant < ApplicationRecord
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Indexable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Tableable

  include Parentable

  # The Edge this Grant is providing rules for
  belongs_to :edge, primary_key: :uuid
  belongs_to :group, inverse_of: :grants
  belongs_to :grant_set
  has_many :permitted_actions, through: :grant_set

  scope :creator, -> { where(grant_set_id: GrantSet.creator.id) }
  scope :spectator, -> { where(grant_set_id: GrantSet.spectator.id) }
  scope :participator, -> { where(grant_set_id: GrantSet.participator.id) }
  scope :initiator, -> { where(grant_set_id: GrantSet.initiator.id) }
  scope :moderator, -> { where(grant_set_id: GrantSet.moderator.id) }
  scope :administrator, -> { where(grant_set_id: GrantSet.administrator.id) }
  scope :staff, -> { where(grant_set_id: GrantSet.staff.id) }

  scope :custom, -> { where('group_id > 0') }

  with_columns settings: [
    NS.schema.name,
    NS.argu[:grantSet],
    NS.ontola[:destroyAction]
  ]

  validates :grant_set, presence: true
  validates :group, presence: true
  validates :edge, presence: true, uniqueness: {scope: :group}

  parentable :edge
  %i[creator spectator participator initiator moderator administrator staff].each do |role|
    define_method "#{role}?" do
      grant_set.title == role
    end
  end

  def display_name
    case edge&.owner_type
    when 'Forum'
      edge.display_name
    when 'Page'
      I18n.t('grants.all_forums')
    else
      I18n.t('grants.other')
    end
  end

  def parent
    @parent ||= edge || ActsAsTenant.current_tenant
  end
  alias edgeable_record parent

  def parent_collections(user_context)
    [group, edge].map do |parent|
      parent_collections_for(parent, user_context)
    end.flatten
  end

  def grant_set=(value)
    value = GrantSet.find_by!(title: value) if value.is_a?(String)
    super
  end

  def page
    parent.root
  end

  class << self
    def attributes_for_new(opts)
      attrs = super.merge(
        grant_set: GrantSet.participator
      )
      parent = opts[:parent]
      if parent.is_a?(Group)
        attrs[:group] = parent
      else
        attrs[:edge] = parent
      end
      attrs
    end
  end
end
