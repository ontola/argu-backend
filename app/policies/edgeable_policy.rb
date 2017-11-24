# frozen_string_literal: true

class EdgeablePolicy < RestrictivePolicy
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
  include EdgeTreePolicy::Roles
  include ChildOperations

  delegate :edge, to: :record
  delegate :persisted_edge, to: :edge
  attr_accessor :outside_tree

  def initialize(context, record)
    super
    raise('No edge available in policy') unless edge
  end

  def has_expired_ancestors?
    context.within_tree?(persisted_edge, outside_tree) ? context.expired?(persisted_edge) : edge.has_expired_ancestors?
  end

  def has_trashed_ancestors?
    context.within_tree?(persisted_edge, outside_tree) ? context.trashed?(persisted_edge) : edge.has_trashed_ancestors?
  end

  def has_unpublished_ancestors?
    if context.within_tree?(persisted_edge, outside_tree)
      context.unpublished?(persisted_edge)
    else
      edge.has_unpublished_ancestors?
    end
  end

  def permitted_attributes
    attributes = super
    if (is_manager? || staff?) && record.is_publishable? && !record.is_a?(Decision) &&
        (!record.is_published? || record.argu_publication&.reactions?)
      attributes.append(:mark_as_important)
    end
    attributes.append(edge_attributes: Pundit.policy(context, record.edge).permitted_attributes) if record.try(:edge)
    attributes
  end

  def convert?
    false
  end

  def move?
    false
  end

  def shift?
    move?
  end

  def show?
    return show_unpublished? if has_unpublished_ancestors?
    rule is_spectator?, is_member?, is_manager?, is_super_admin?, super
  end

  def create?
    return create_expired? if has_expired_ancestors?
    return create_trashed? if has_trashed_ancestors?
    rule is_member?, is_manager?, is_super_admin?, super
  end

  def trash?
    rule is_manager?, is_super_admin?, staff?
  end
  alias bin? trash?

  def untrash?
    trash?
  end
  alias unbin? trash?

  def destroy?
    return super if edge.children_counts.values.map(&:to_i).sum.positive?
    rule is_creator?, staff?
  end

  def follow?
    rule is_spectator?, is_member?, is_super_admin?, staff?
  end

  def log?
    rule is_manager?, is_super_admin?, staff?
  end

  def feed?
    rule show?
  end

  def invite?
    false
  end

  def statistics?
    rule is_manager?, is_super_admin?, staff?
  end

  private

  def cache_action(action, val)
    user_context.cache_key(edge.id, action, val)
  end

  def change_owner?
    staff?
  end

  def check_action(action)
    user_context.check_key(edge.id, action)
  end

  def create_expired?
    nil
  end

  def create_trashed?
    false
  end

  def parent_policy(type = nil)
    Pundit.policy(context, record.parent_model(type))
  end

  def show_unpublished?
    update?
  end
end
