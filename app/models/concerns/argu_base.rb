module ArguBase
  extend ActiveSupport::Concern

  included do
  end

  def edited?
    updated_at - 2.minutes > created_at
  end

  def identifier
    "#{class_name}_#{id}"
  end

  def class_name
    self.class.name.tableize
  end

  module ClassMethods
    def class_name
      name.tableize
    end
  end
end
