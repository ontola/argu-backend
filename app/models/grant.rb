# frozen_string_literal: true

class Grant < ApplicationRecord # rubocop:disable Metrics/ClassLength
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable

  include Cacheable
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
  collection_options(
    association_base: -> { Grant.collection_items(self) },
    include_members: true
  )

  %i[creator spectator participator initiator moderator administrator].each do |role|
    define_method "#{role}?" do
      grant_set.title == role
    end
  end

  def added_delta
    super + GrantTree::PermissionGroup.invalidate_all_delta
  end

  def display_name
    case edge
    when ContainerNode
      edge.display_name
    when Page
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

  def grant_set_id=(value)
    if value.blank?
      mark_for_destruction
      edge.send(:association_has_destructed, :grants)
    else
      super
    end
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
        attrs[:edge] = parent if parent.is_a?(Edge)
      end
      attrs
    end

    def collection_items(collection)
      grants = collection.parent.try(:grants)&.to_a || []
      missing_groups = Group.pluck(:id) - grants.map(&:group_id)
      missing_grants = missing_groups.map do |group_id|
        Grant.new(group_id: group_id)
      end

      (grants + missing_grants).sort_by(&:group_id)
    end

    def requested_index_resource(params, user_context)
      return super unless params[:parent_iri]&.end_with?('/action_object')

      collection_or_view = root_collection(**index_collection_params(params, user_context))
      collection = collection_or_view.is_a?(Collection) ? collection_or_view : collection_or_view.collection
      collection.parent_iri = params[:parent_iri].split('/')
      collection_or_view
    end
  end
end
