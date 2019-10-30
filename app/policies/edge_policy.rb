# frozen_string_literal: true

class EdgePolicy < RestrictivePolicy # rubocop:disable Metrics/ClassLength
  class Scope < EdgeTreePolicy::Scope
    def class_name
      self.class.name.split('Policy')[0]
    end

    def resolve
      scope
        .active
        .joins(:parent)
        .with(granted_paths)
        .where(root_id: grant_tree.tree_root_id)
        .where(granted_path_type_filter)
    end
  end
  include ChildOperations

  delegate :persisted_edge, to: :record
  attr_reader :grant_tree

  def initialize(context, record)
    super
    raise('No edge available in policy') unless record
    @grant_tree = init_grant_tree
  end

  %i[spectator participator moderator administrator staff].each do |role|
    define_method "#{role}?" do
      return instance_variable_get("@#{role}") if instance_variable_defined?("@#{role}")
      instance_variable_set("@#{role}", has_grant_set?(role))
    end
  end

  def has_expired_ancestors?
    grant_tree.expired?(persisted_edge)
  end

  def has_trashed_ancestors?
    grant_tree.trashed?(persisted_edge)
  end

  def has_unpublished_ancestors?
    grant_tree.unpublished?(persisted_edge)
  end

  def has_grant?(action, check_class = class_name)
    return true if service?

    group_ids =
      grant_tree
        .granted_group_ids(
          persisted_edge,
          action: action,
          resource_type: check_class,
          parent_type: record&.parent&.owner_type
        )
    (group_ids & user.profile.group_ids).any?
  end

  def has_grant_set?(grant_set)
    return false if grant_tree.nil?
    grant_tree
      .grant_sets(persisted_edge, group_ids: user.profile.group_ids)
      .include?(grant_set.to_s)
  end

  def permitted_attribute_names
    attributes = super
    attributes.append(:mark_as_important) if mark_as_important?
    attributes.append(:creator) if new_record? && !user.guest?
    attributes.concat %i[id expires_at] if expires_at?
    attributes.concat([:url, shortname_attributes: %i[shortname id]]) if shortname?
    attributes
  end

  def convert?
    false
  end

  def contact?
    administrator? || staff?
  end

  def list?
    true
  end

  def move?
    false
  end

  def shift?
    move?
  end

  def show?
    return if has_unpublished_ancestors? && !show_unpublished?
    has_grant?(:show)
  end

  def create?
    return create_expired? if has_expired_ancestors?
    return create_trashed? if has_trashed_ancestors?
    has_grant?(:create)
  end

  def trash?
    has_grant?(:trash)
  end
  alias bin? trash?

  def untrash?
    trash?
  end
  alias unbin? trash?

  def update?
    is_creator? || has_grant?(:update)
  end

  def destroy?
    return super if has_content_children?
    is_creator? || has_grant?(:destroy)
  end

  def follow?
    show?
  end

  def log?
    update?
  end

  def feed?
    show?
  end

  def invite?
    false
  end

  def publish?
    !record.is_published? && update?
  end

  def statistics?
    has_grant?(:update)
  end

  def shortname?
    new_record? || update?
  end

  private

  def cache_action(action, val)
    user_context.cache_key(record.id, action, val)
  end

  def check_action(action)
    user_context.check_key(record.id, action)
  end

  def class_name
    self.class.name.split('Policy')[0]
  end

  def create_expired?
    nil
  end

  def create_trashed?
    false
  end

  def expires_at?
    %w[Motion Question].include?(record.owner_type) && (moderator? || administrator? || staff?)
  end

  def has_content_children?
    record.children_counts.except('votes_con', 'votes_neutral', 'votes_pro').values.map(&:to_i).sum.positive?
  end

  def init_grant_tree
    context.grant_tree_for(record)
  end

  def is_creator?
    return if record.creator_id.blank?
    record.publisher_id == user.id || user.managed_profile_ids.include?(record.creator_id)
  end

  def mark_as_important? # rubocop:disable Metrics/AbcSize
    (moderator? || administrator? || staff?) &&
      record.is_publishable? &&
      !record.is_a?(Decision) &&
      (!record.argu_publication&.attribute_in_database(:published_at) || record.argu_publication&.reactions?)
  end

  def parent_policy(type = nil)
    Pundit.policy(context, record.ancestor(type))
  end

  def show_unpublished?
    update? || (record.is_published? && parent_policy.show?)
  end
end
