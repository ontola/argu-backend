# frozen_string_literal: true

class EdgePolicy < RestrictivePolicy # rubocop:disable Metrics/ClassLength
  class Scope < EdgeTreePolicy::Scope
    def class_name
      self.class.name.split('Policy')[0]
    end

    def resolve
      return scope.none if user.nil?

      scope
        .where(active_or_creator)
        .joins(:parent)
        .with(granted_paths)
        .joins(granted_path_type_join)
        .where(root_id: grant_tree.tree_root_id)
    end
  end

  permit_attributes %i[expires_at], grant_sets: %i[moderator administrator staff]
  permit_attributes %i[creator], creator: true, new_record: true
  permit_attributes %i[url]

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

  def granted_group_ids(action_name, check_class = class_name)
    return [] if grant_tree.nil?

    grant_tree
      .granted_group_ids(
        persisted_edge,
        action_name: action_name,
        resource_type: check_class,
        parent_type: parent_type
      )
  end

  def has_expired_ancestors?
    grant_tree&.expired?(persisted_edge)
  end

  def has_trashed_ancestors?
    grant_tree&.trashed?(persisted_edge)
  end

  def has_unpublished_ancestors?
    grant_tree&.unpublished?(persisted_edge)
  end

  def has_grant?(action_name, check_class = class_name)
    return true if service?

    (granted_group_ids(action_name, check_class) & user.profile.group_ids).any?
  end

  def has_grant_set?(grant_set)
    user_context.has_grant_set?(persisted_edge, grant_set) if persisted_edge
  end

  def convert?
    false
  end

  def contact?
    return false unless administrator? || staff?
    return forbid_wrong_tier unless feature_enabled?(:direct_messages)

    true
  end

  def expired?
    has_expired_ancestors?
  end

  def list?
    true
  end

  def move?
    false
  end

  def public_resource?
    granted_group_ids(:show).include?(Group::PUBLIC_ID)
  end

  def show?
    return if has_unpublished_ancestors? && !show_unpublished?
    return true if record.owner_type == 'Edge' && record.new_record?

    has_grant?(:show)
  end

  def create?
    return create_expired? if has_expired_ancestors?
    return create_trashed? if has_trashed_ancestors?
    return false unless has_grant?(:create)
    return forbid_wrong_tier if wrong_tier?

    true
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
    return has_grant?(:destroy) if has_content_children?

    is_creator? || has_grant?(:destroy)
  end

  def follow?
    show?
  end

  def log?
    update?
  end

  def invite?
    false
  end

  def statistics?
    has_grant?(:update)
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

  def has_content_children?
    record
      .children
      .where.not(owner_type: %w[Vote VoteEvent])
      .where.not(publisher_id: record.publisher_id)
      .any?
  end

  def init_grant_tree
    context.grant_tree_for(record)
  end

  def is_creator?
    return if record.creator_id.blank?
    return current_session? if record.creator_id == User::GUEST_ID

    record.publisher_id == user.id || managed_profile_ids.include?(record.creator_id)
  end

  def parent_policy(type = nil)
    Pundit.policy(context, record.ancestor(type))
  end

  def parent_type
    return record.parent&.owner_type if record&.association_cached?(:parent)

    record && Edge.where(id: record&.parent_id).pluck(:owner_type).first
  end

  def show_unpublished?
    update? || (record.is_published? && parent_policy.show?)
  end

  def required_feature
    feature = policy_class.name.tableize

    feature if Rails.application.config.tiers.key?(feature)
  end

  def wrong_tier?
    return false unless required_feature

    !feature_enabled?(required_feature)
  end
end
