# frozen_string_literal: true

class ConversionPolicy < EdgeTreePolicy
  class Scope < RestrictivePolicy::Scope
    def resolve
      scope
    end
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[klass]
    attributes
  end

  def create?
    klass = record.klass.is_a?(String) ? record.klass : record.klass.class_name
    assert! record.edge.owner.try(:convertible_classes)&.include?(klass.to_sym), :convert_class?
    assert! Pundit.policy(context, edgeable_record).convert?, :convert?
    true
  end
end
