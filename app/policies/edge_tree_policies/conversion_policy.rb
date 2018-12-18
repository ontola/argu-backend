# frozen_string_literal: true

class ConversionPolicy < EdgeTreePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[klass]
    attributes
  end

  def create? # rubocop:disable Metrics/AbcSize
    klass = record.klass.is_a?(String) ? record.klass : record.klass.class_name
    assert! record.edge.try(:convertible_classes)&.include?(klass.to_sym), :convert_class?
    assert! Pundit.policy(context, edgeable_record).convert?, :convert?
    true
  end
end
