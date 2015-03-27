module Parentable
  extend ActiveSupport::Concern

  included do
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

  # :nodoc:
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
    def parentable(*relation)
      cattr_accessor :parent_is do
        relation
      end
    end
  end
end
