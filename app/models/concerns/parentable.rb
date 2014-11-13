module Parentable
  extend ActiveSupport::Concern

  included do
  end

  def get_parent
    if self.class.reflect_on_association(parent_is).macro == :belongs_to
      send(parent_is)
    else
      send(parent_is).first
    end
  end

  module ClassMethods
    def parentable(relation)
      cattr_accessor :parent_is do
        relation
      end
    end
  end
end
