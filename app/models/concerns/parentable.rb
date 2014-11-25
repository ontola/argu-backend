module Parentable
  extend ActiveSupport::Concern

  included do
  end

  # Gives the context of an object based on the parameters (if needed/any)
  # @return Hash with :model pointing to the model or collection, and :url as the visitable url
  def get_parent(options={})
    parent = Context.new
    if self.class.reflect_on_association(parent_is).macro == :belongs_to
      parent.model = send(parent_is)
    else
      begin
        parent.model = send(parent_is).find(options["#{parent_is.to_s.singularize}_id"])
      rescue ActiveRecord::RecordNotFound
        parent.model = nil
      end
    end
    parent
  end

  module ClassMethods
    def parentable(relation)
      cattr_accessor :parent_is do
        relation
      end
    end
  end
end
