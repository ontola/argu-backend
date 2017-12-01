# frozen_string_literal: true

module ChildOperations
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
        if child.is_a?(Edgeable::Base)
          child.creator = Profile.new(are_votes_public: true) if child.respond_to?(:creator=)
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
end