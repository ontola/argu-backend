# frozen_string_literal: true

class ConversionPolicy < EdgeTreePolicy
  permit_attributes %i[klass_iri]

  def create?
    return true if record.klass_iri.nil?
    return forbid_with_message(I18n.t('actions.conversions.create.errors.invalid_class')) unless valid_class?
    return unless Pundit.policy(context, edgeable_record).convert?

    true
  end

  private

  def valid_class?
    record.edge.try(:convertible_classes)&.include?(record.klass.name.tableize.to_sym)
  end
end
