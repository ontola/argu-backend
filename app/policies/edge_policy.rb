# frozen_string_literal: true

class EdgePolicy < RestrictivePolicy
  class Scope < EdgeTreePolicy::Scope
    def class_name
      self.class.name.split('Policy')[0]
    end

    def resolve
      scope
        .joins(:edge)
        .where("edges.path ? #{Edge.path_array(granted_edges_within_tree || user.profile.granted_edges)}")
        .published
        .untrashed
    end
  end
  include ChildOperations

  delegate :edge, to: :record
  delegate :persisted_edge, to: :edge
  attr_reader :grant_tree

  def initialize(context, record)
    super
    raise('No edge available in policy') unless edge
    @grant_tree = context.grant_tree_for(edge)
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

  def has_grant?(action)
    group_ids =
      grant_tree
        .granted_group_ids(
          persisted_edge,
          action: action,
          resource_type: class_name,
          parent_type: edge&.parent&.owner_type
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
    attributes.append(edge_attributes: Pundit.policy(context, record.edge).permitted_attributes) if record.try(:edge)
    attributes.concat([:url, shortname_attributes: %i[shortname id]]) if shortname?
    attributes
  end

  def convert?
    false
  end

  def contact?
    administrator? || staff?
  end

  def move?
    false
  end

  def shift?
    move?
  end

  def show?
    return show_unpublished? if has_unpublished_ancestors?
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
    return super if edge.children_counts.values.map(&:to_i).sum.positive?
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

  def statistics?
    has_grant?(:update)
  end

  def shortname?
    new_record? || update?
  end

  private

  def cache_action(action, val)
    user_context.cache_key(edge.id, action, val)
  end

  def check_action(action)
    user_context.check_key(edge.id, action)
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

  def is_creator?
    return if record.creator.blank?
    record.creator == actor || user.managed_profile_ids.include?(record.creator.id)
  end

  def mark_as_important?
    (moderator? || administrator? || staff?) &&
      record.is_publishable? &&
      !record.is_a?(Decision) &&
      (!record.is_published? || record.argu_publication&.reactions?)
  end

  def parent_policy(type = nil)
    Pundit.policy(context, record.parent_model(type))
  end

  def show_unpublished?
    update?
  end
end
