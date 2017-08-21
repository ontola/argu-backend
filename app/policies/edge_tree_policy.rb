# frozen_string_literal: true
class EdgeTreePolicy < RestrictivePolicy
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

  delegate :has_expired_ancestors?, :has_trashed_ancestors?, :has_unpublished_ancestors?, to: :edgeable_policy

  def initialize(context, record)
    super
    raise('No edgeable record avaliable in policy') unless edgeable_record
  end

  def permitted_attributes
    attributes = super
    #if (is_manager? || staff?) && record.is_publishable? && !record.is_a?(Decision) &&
    #    (!record.is_published? || record.argu_publication&.reactions?)
      attributes.append(:mark_as_important)
    #end
    attributes.append(edge_attributes: Pundit.policy(context, record.edge).permitted_attributes) if record.try(:edge)
    attributes
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

  def create_expired?
    nil
  end

  def create_trashed?
    false
  end

  def show_unpublished?
    rule is_creator?, is_manager?, is_super_admin?, staff?, service?
  end

  def edgeable_policy
    @edgeable_policy ||= Pundit.policy(context, edgeable_record)
  end

  def edgeable_record; end
end
