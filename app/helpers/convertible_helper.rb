# Contains argu-specific implementation details of {Convertible}
module ConvertibleHelper
  def convertible_param_to_model(convertible)
    Hash[convertible_classes.map { |a| [a.class_name, a] }][convertible]
  end

  def convertible_class_names
    convertible_classes.map(&:class_name)
  end

  # @private The model classes which are currently convertible with each other
  def convertible_classes
    [Question, Motion]
  end
end
