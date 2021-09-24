# frozen_string_literal: true

class ConversionPolicy < EdgeTreePolicy
  permit_attributes %i[klass_iri]

  def create?
    return true if record.klass_iri.nil?
    return unless record.edge.try(:convertible_classes)&.include?(record.klass.name.tableize.to_sym)
    return unless Pundit.policy(context, edgeable_record).convert?

    true
  end
end
