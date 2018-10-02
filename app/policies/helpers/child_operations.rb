# frozen_string_literal: true

module ChildOperations
  include ChildHelper

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

    r = valid_child?(klass) && Pundit.policy(context, child_instance(record, klass)).send(method) || false
    cache_action(cache_key, r)
    r
  end

  def valid_child?(klass)
    valid_parents = valid_parents_for(klass)
    valid_parents.include?(record.class.name.underscore.to_sym) ||
      record.is_a?(Edge) && valid_parents.include?(:edge)
  end

  def valid_parents_for(klass)
    klass.try(:parent_classes) || []
  end
end
