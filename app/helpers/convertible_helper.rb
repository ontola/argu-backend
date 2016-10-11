# frozen_string_literal: true
# Contains argu-specific implementation details of {Convertible}
module ConvertibleHelper
  def convertible_class_names(record)
    record.convertible_classes.keys.map(&:to_s)
  end
end
