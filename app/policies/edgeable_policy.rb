# frozen_string_literal: true
# frozen_string_literal: true
class EdgeablePolicy < RestrictivePolicy
  class Scope < RestrictivePolicy::Scope
    def class_name
      self.class.name.split('Policy')[0]
    end

    def resolve
      return scope.published.untrashed if staff?
      scope
        .joins(:edge)
        .where("edges.path ? #{Edge.path_array(granted_edges_within_tree || user.profile.granted_edges)}")
        .published
        .untrashed
    end

    def granted_edges_within_tree
      return unless context.has_tree?
      user.profile.granted_edges.where('path <@ ?', context.tree_root.id.to_s)
    end
  end

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

  def permitted_publish_types
    Publication.publish_types
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

  def create?
    assert_publish_type
    return create_expired? if has_expired_ancestors?
    return create_trashed? if has_trashed_ancestors?
    grant_available?(:create)
  end

  def destroy?
    return staff? if edge.children.any?
    is_creator? || staff?
  end

  def follow?
    show?
  end

  def move?
    staff?
  end

  def show?
    return show_unpublished? if has_unpublished_ancestors?
    grant_available?(:show)
  end

  def trash?
    grant_available?(:trash)
  end
  alias untrash? trash?

  def update?
    grant_available?(:update)
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

  def change_owner?
    staff?
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

  def create_expired?
    false
  end

  def create_trashed?
    false
  end

  # @todo this does not take multiple groups into account. If the last result sets permit: false for group A, while group B is still permitted, this returns false
  def grant_available?(action)
    return true if staff?
    path_ids = persisted_edge.path.split('.')
    Grant
      .order("idx(array[#{path_ids.join(',')}], grants.edge_id) DESC")
      .where(
        group_id: user.profile.group_ids,
        edge_id: path_ids,
        model_type: record.class.name,
        parent_type: ['*', record.parent_model.class.name],
        action: action
      )
      .limit(1)
      .pluck(:permit)
      .first
  end

  def is_creator?
    return if record.creator.blank?
    record.creator == actor || user.managed_profile_ids.include?(record.creator.id)
  end

  def show_unpublished?
    update?
  end
end
