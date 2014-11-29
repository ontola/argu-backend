module ArguBase
  extend ActiveSupport::Concern

  included do

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
