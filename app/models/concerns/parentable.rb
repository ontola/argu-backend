module Parentable
  extend ActiveSupport::Concern

  included do
  end

  # Gives the context of an object based on the parameters (if needed/any)
  # @return Hash with :model pointing to the model or collection, and :url as the visitable url
  def get_parent(options={})
    if parent_is.class == Symbol
      parent = reflect_parent(parent_is, options)
    elsif parent_is.class == Array
      parent_is.each do |_parent|
        parent = reflect_parent(_parent, options)
        parent || break
      end
    end
    parent || Context.new
  end

  def reflect_parent(relation_name, options)
    parent = Context.new
    if self.class.reflect_on_association(relation_name).macro == :belongs_to
      parent.model = send(relation_name)
    else
      begin
        parent.model = send(relation_name).find(options["#{relation_name.to_s.singularize}_id"])
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
