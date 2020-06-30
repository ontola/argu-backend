# frozen_string_literal: true

class ConversionPolicy < EdgeTreePolicy
  permit_attributes %i[klass]

  def create? # rubocop:disable Metrics/AbcSize
    klass = record.klass.is_a?(String) ? record.klass : record.klass.class_name
    return unless record.edge.try(:convertible_classes)&.include?(klass.to_sym)
    return unless Pundit.policy(context, edgeable_record).convert?

    true
  end
end
