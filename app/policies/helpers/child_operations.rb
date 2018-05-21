# frozen_string_literal: true

module ChildOperations
  # Checks whether creating a child of a given class is allowed
  # Initialises a child with the given attributes and checks its policy for new?
  # @param raw_klass [Symbol] the class of the child
  # @return [Integer, false] The user's clearance level
  def create_child?(raw_klass)
    child_operation(:create?, raw_klass)
  end

  # Checks whether indexing children of a has_many relation is allowed
  # Initialises a child with the given attributes and checks its policy for show?
  # @param raw_klass [Symbol] the class of the child
  # @return [Integer, false] The user's clearance level
  def index_children?(raw_klass)
    child_operation(:show?, raw_klass)
  end

  private

  # Initialises a child of the type {raw_klass} with the given {attrs} and checks
  #   its policy for `{method}?`
  # @return [Boolean] Whether the action is allowed. Returns a cached value when
  #   the combination {method} {klass} is already evaluated.
  def child_operation(method, raw_klass)
    klass = raw_klass.to_s.classify.constantize
    cache_key = "#{method}_child_for_#{klass}?".to_sym
    c = check_action(cache_key)
    return c unless c.nil?

    r = valid_parent?(klass) && Pundit.policy(context, child_instance(klass)).send(method) || false
    cache_action(cache_key, r)
    r
  end

  def child_instance(klass)
    child = klass.new(child_attrs(klass))
    if child.is_a?(EdgeableBase)
      child.creator = Profile.new(are_votes_public: true) if child.respond_to?(:creator=)
      child = record.edge.children.new(owner: child, is_published: true).owner
      child.edge.persisted_edge = persisted_edge
      child.edge.parent = record.edge
      child.parent_model = record
      grant_tree.cache_node(persisted_edge)
    end
    child
  end

  def child_attrs(raw_klass)
    case raw_klass.to_s
    when 'Discussion'
      {forum: record}
    when 'Export', 'Favorite', 'GrantTree', 'Grant'
      {edge: record.is_a?(Edge) ? record : record.edge}
    when 'GroupMembership'
      {group: record}
    when 'Group'
      {page: record}
    when 'MediaObject'
      {about: record}
    when 'Decision'
      {state: 'forwarded'}
    else
      {}
    end
  end

  def valid_parent?(klass)
    return false unless klass.respond_to?(:parent_classes)
    klass.parent_classes.include?(record.class.base_class.name.underscore.to_sym) ||
      record.is_a?(EdgeableBase) && klass.parent_classes.include?(:edge)
  end
end
