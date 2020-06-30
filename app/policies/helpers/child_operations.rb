# frozen_string_literal: true

module ChildOperations
  include ChildHelper

  # Checks whether creating a child of a given class is allowed
  # Initialises a child with the given attributes and checks its policy for new?
  # @param raw_klass [Symbol] the class of the child
  # @return [Integer, false] The user's clearance level
  def create_child?(raw_klass, opts = {})
    child_operation(:create?, raw_klass, opts)
  end

  # Checks whether indexing children of a has_many relation is allowed
  # Initialises a child with the given attributes and checks its policy for show?
  # @param raw_klass [Symbol] the class of the child
  # @return [Integer, false] The user's clearance level
  def index_children?(raw_klass, opts = {})
    child_operation(:show?, raw_klass, opts)
  end

  private

  def authorize_child_operation(method, klass, opts = {})
    Pundit.policy(context, child_instance(record, klass, opts)).send(method) || false
  end

  # Initialises a child of the type {raw_klass} with the given {attrs} and checks
  #   its policy for `{method}?`
  # @return [Boolean] Whether the action is allowed. Returns a cached value when
  #   the combination {method} {klass} is already evaluated.
  def child_operation(method, raw_klass, opts = {})
    klass = raw_klass.to_s.classify.constantize
    cache_key = "#{method}_child_for_#{klass}?".to_sym
    c = check_action(cache_key)
    return c unless c.nil?

    r = (method == :show? || valid_child?(klass)) && authorize_child_operation(method, klass, opts)
    cache_action(cache_key, r)
    r
  end

  def valid_child?(klass)
    klass.valid_parent?(record.class)
  end
end
