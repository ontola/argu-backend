# frozen_string_literal: true
class EdgeablePolicy < RestrictivePolicy
  class Scope < RestrictivePolicy::Scope; end

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
    action = new_record? ? 'create' : 'update'
    persisted_edge.permitted_attributes(class_name, action, granted_group_ids(action))
  end

  def has_grant?(action)
    granted_group_ids(action).any?
  end

  def granted_group_ids(action)
    persisted_edge.granted_group_ids(class_name, action, '*') & user.profile.group_ids
  end

  def has_grant_set?(title)
    user
      .profile
      .grants
      .joins(:grant_set)
      .where(edge_id: edge.path.split('.'), grant_sets: {title: title})
      .present?
  end

  def permitted_publish_types
    publish_types = Publication.publish_types
    has_grant?(:schedule) ? publish_types : publish_types.except('schedule')
  end

  # Checks whether creating a child of a given class is allowed
  # Initialises a child with the given attributes and checks its policy for new?
  # @param raw_klass [Symbol] the class of the child
  # @param attrs [Hash] attributes used for initialising the child
  # @return [Integer, false] The user's clearance level
  def create_child?(raw_klass, attrs = {})
    child_operation(:create?, raw_klass, attrs)
  end

  # Checks whether indexing children of a has_many relation is allowed
  # Initialises a child with the given attributes and checks its policy for show?
  # @param raw_klass [Symbol] the class of the child
  # @param attrs [Hash] attributes used for initialising the child
  # @return [Integer, false] The user's clearance level
  def index_children?(raw_klass, attrs = {})
    child_operation(:show?, raw_klass, attrs)
  end

  def convert?
    false
  end

  def move?
    staff?
  end

  def create?
    assert_publish_type
    return create_expired? if has_expired_ancestors?
    return create_trashed? if has_trashed_ancestors?
    has_grant?(:create)
  end

  def show?
    has_grant?(:show)
  end

  def update?
    has_grant?(:update)
  end

  def trash?
    has_grant?(:destroy)
  end

  def untrash?
    trash?
  end

  def destroy?
    has_grant?(:destroy)
  end

  def follow?
    show?
  end

  def feed?
    show?
  end

  private

  def assert_publish_type
    return if record.edge.argu_publication&.publish_type.nil?
    assert! permitted_publish_types.include?(record.edge.argu_publication.publish_type),
            "#{record.edge.argu_publication.publish_type}?"
  end

  def cache_action(action, val)
    user_context.cache_key(edge.id, action, val)
  end

  def check_action(action)
    user_context.check_key(edge.id, action)
  end

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
        if child.is_edgeable?
          child = record.edge.children.new(owner: child, is_published: true).owner
          child.edge.persisted_edge = persisted_edge
          child.parent_model = record
          context.cache_node(persisted_edge) if context.within_tree?(persisted_edge, outside_tree)
        end
        Pundit.policy(context, child).send(method) || false
      else
        false
      end
    cache_action(cache_key, r) if attrs.empty?
    r
  end

  def class_name
    self.class.name.split('Policy')[0]
  end

  def create_expired?
    false
  end

  def create_trashed?
    false
  end

  def show_unpublished?
    rule is_creator?, is_manager?, is_super_admin?, staff?, service?
  end
end
