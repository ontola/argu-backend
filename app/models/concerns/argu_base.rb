module ArguBase
  extend ActiveSupport::Concern

  included do
  end

  def edited?
    self.updated_at - 2.minutes > self.created_at
  end

  def identifier
    "#{self.class_name}_#{self.id}"
  end

  def class_name
    self.class.name.tableize
  end

  module ClassMethods
    def class_name
      self.name.tableize
    end
  end
end
