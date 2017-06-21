# frozen_string_literal: true
class EdgeTreePolicy < RestrictivePolicy
  class Scope < RestrictivePolicy::Scope
    def class_name
      self.class.name.split('Policy')[0]
    end

    def resolve
      return scope.published.untrashed if staff?
      scope
        .published
        .untrashed
        .joins("LEFT JOIN forums ON #{class_name.tableize}.forum_id = forums.id")
        .where("#{class_name.tableize}.forum_id IS NULL OR #{class_name.tableize}.forum_id IN (?) ",
               user.profile.forum_ids)
    end
  end

  module Roles
    def open
      1
    end

    def spectator
      2
    end

    def member
      3
    end

    # Not an actual role, but reserved nevertheless
    def group_grant
      5
    end

    def manager
      7
    end

    def owner
      8
    end

    def super_admin
      10
    end

    def is_role?(role)
      return if persisted_edge.nil?
      if context.within_tree?(persisted_edge)
        send(role) if context.granted_group_ids(persisted_edge, role.to_s).any?
      elsif (user.profile.group_ids & persisted_edge.granted_group_ids(role.to_s)).any?
        send(role)
      end
    end

    def is_spectator?
      is_role?(:spectator)
    end

    def is_member?
      is_role?(:member)
    end

    def is_creator?
      creator if record.creator.present? && record.creator == actor
    end

    def is_manager?
      is_role?(:manager) || is_role?(:super_admin)
    end

    def is_super_admin?
      is_role?(:super_admin)
    end

    def is_manager_up?
      is_manager? || is_super_admin? || staff?
    end
  end
  include Roles
  delegate :edge, to: :record
  delegate :persisted_edge, to: :edge

  def has_expired_ancestors?
    context.within_tree?(persisted_edge) ? context.expired?(persisted_edge) : edge.has_expired_ancestors?
  end

  def has_unpublished_ancestors?
    context.within_tree?(persisted_edge) ? context.unpublished?(persisted_edge) : edge.has_unpublished_ancestors?
  end

  def initialize(context, record)
    super
    raise('No edge avaliable in policy') unless edge
  end

  def cache_action(action, val)
    user_context.cache_key(edge.id, action, val)
  end

  def check_action(action)
    user_context.check_key(edge.id, action)
  end

  def assert_publish_type
    return if record.edge.argu_publication&.publish_type.nil?
    assert! permitted_publish_types.include?(record.edge.argu_publication.publish_type),
            "#{record.edge.argu_publication.publish_type}?"
  end

  def context_forum
    @context_forum ||= persisted_edge.get_parent(:forum)&.owner
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

  def permitted_publish_types
    Publication.publish_types
  end

  def change_owner?
    rule staff?
  end

  def convert?
    false
  end

  # Checks whether creating a child of a given class is allowed
  # Initialises a child with the given attributes and checks its policy for new?
  # @param raw_klass [Symbol] the class of the child
  # @param attrs [Hash] attributes used for initialising the child
  # @return [Integer, false] The user's clearance level
  def create_child?(raw_klass, attrs = {})
    child_operation(:create?, raw_klass, attrs)
  end

  def follow?
    rule is_member?, is_super_admin?, staff?
  end

  # Checks whether indexing children of a has_many relation is allowed
  # Initialises a child with the given attributes and checks its policy for show?
  # @param raw_klass [Symbol] the class of the child
  # @param attrs [Hash] attributes used for initialising the child
  # @return [Integer, false] The user's clearance level
  def index_children?(raw_klass, attrs = {})
    child_operation(:show?, raw_klass, attrs)
  end

  def log?
    rule is_manager?, is_super_admin?, staff?
  end

  def feed?
    rule show?
  end

  # Move items between forums or converting items
  def move?
    staff?
  end

  def shift?
    move?
  end

  def show_unpublished?
    rule is_creator?, is_manager?, is_super_admin?, staff?, service?
  end

  def create_expired?
    nil
  end

  def trash?
    staff?
  end

  def untrash?
    staff?
  end

  def vote?
    staff?
  end

  def show?
    return show_unpublished? if has_unpublished_ancestors?
    rule is_spectator?, is_member?, is_manager?, is_super_admin?, super
  end

  private

  # Initialises a child of the type {raw_klass} with the given {attrs} and checks
  #   its policy for `{method}?`
  # @return [Boolean] Whether the action is allowed. Returns a cached value when
  #   the combination {method} {klass} is already evaluated.
  def child_operation(method, raw_klass, attrs = {})
    klass = raw_klass.to_s.classify.constantize
    if attrs.empty?
      cache_key = "#{method}_child_for_#{klass}?".to_sym
      c = check_action(cache_key)
      return c unless c.nil?
    end

    r =
      if klass.parent_classes.include?(record.class.name.underscore.to_sym)
        child = klass.new(attrs)
        if child.is_fertile?
          child = record.edge.children.new(owner: child, is_published: true).owner
          context.cache_node(persisted_edge) if context.within_tree?(persisted_edge)
        end
        Pundit.policy(context, child).send(method) || false
      else
        false
      end
    cache_action(cache_key, r) if attrs.empty?
    r
  end

  def parent_policy
    Pundit.policy(context, record.parent_model)
  end
end
