# Concern that gives models the `Parentable` functionality in cooperation with {Context}
#
# A model using Parentable needs to call {Parentable::ClassMethods#parentable} to define which associations
# qualify to be parent.
module Parentable
  extend ActiveSupport::Concern

  included do
    # Simple method to verify that a model uses {Parentable}
    def is_fertile?
      true
    end
  end

  # Gives the context of an object based on the parameters (if needed/any)
  # @return Hash with :model pointing to the model or collection, and :url as the visitable url
  def get_parent(options={})
    if parent_is.class == Symbol
      parent = reflect_parent(parent_is, options)
    elsif parent_is.class == Array
      parent_is.each do |_parent|
        __parent = reflect_parent(_parent, options)
        parent ||= __parent if __parent.model.present?
        parent && break
      end
    end
    parent || Context.new
  end

  # Check if this model is a child of `record`
  def is_child_of?(record)
    parent = self.get_parent
    if parent
      if parent.model == record
        true
      elsif parent.has_parent?
        if parent.model.try(:is_fertile?)
            parent.model.is_child_of?(record)
        end
      else
        # This is false since it can't be parent of itself
        false
      end
    else
      false
    end
  end

  # @private
  def reflect_parent(relation_name, options)
    parent = Context.new
    if relation_name == :self
      parent.model = self
    elsif self.class.reflect_on_association(relation_name).macro == :belongs_to
      parent.model = send(relation_name)
    else
      begin
        #@TODO This might not stand when using generic has_many relations
        #parent.model = send(relation_name).find(options["#{relation_name.to_s.singularize}_id"])
        parent.model = send(relation_name)
      rescue ActiveRecord::RecordNotFound
        parent.model = nil
      end
    end
    parent
  end

  module ClassMethods
    # Add to a model which includes {Parentable} to set the possible parents for the model
    # @param relation [Symbol splat] List of symbolized model names.
    def parentable(*relation)
      cattr_accessor :parent_is do
        relation
      end
    end
  end

  module ActiveRecordExtension
    def self.included(base)
      base.class_eval do
        def self.is_fertile?
          false
        end
      end
    end

    # Useful to test whether a model is (not) fertile
    def is_fertile?
      false
    end
  end
  ActiveRecord::Base.send(:include, ActiveRecordExtension)
end
