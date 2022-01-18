# frozen_string_literal: true

class Grant < ApplicationRecord
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable

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

  with_columns(
    settings: [
      NS.argu[:target],
      NS.argu[:grantSet],
      NS.ontola[:destroyAction]
    ],
    grant_tree: [
      NS.argu[:group],
      NS.argu[:target],
      NS.argu[:grantSet],
      NS.ontola[:destroyAction]
    ]
  )

  validates :grant_set, presence: true
  validates :group, presence: true
  validates :edge, presence: true, uniqueness: {scope: :group}

  parentable :edge
  %i[creator spectator participator initiator moderator administrator staff].each do |role|
    define_method "#{role}?" do
      grant_set.title == role
    end
  end

  def added_delta
    super + [
      [NS.sp.Variable, RDF.type, NS.argu['GrantTree::PermissionGroup'], NS.ontola[:invalidate]]
    ]
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
    [group, edge, edge.grant_tree_node(user_context)].flatten.map do |parent|
      parent_collections_for(parent, user_context)
    end.flatten + [edge.grant_tree_node(user_context).permission_group_collection]
  end

  def grant_set=(value)
    value = GrantSet.find_by!(title: value) if value.is_a?(String)
    super
  end

  def page
    parent.root
  end

  class << self
    def attributes_for_new(opts) # rubocop:disable Metrics/MethodLength
      attrs = super.merge(
        grant_set: GrantSet.participator
      )
      parent = opts[:parent]
      case parent
      when GrantTree::Node
        attrs[:edge] = parent.edgeable_record
      when Group
        attrs[:group] = parent
      else
        attrs[:edge] = parent
      end
      attrs
    end
  end
end
