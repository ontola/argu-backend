# frozen_string_literal: true

class ConversionActionList < ApplicationActionList
  private

  def association_class
    Conversion
  end

  def create_on_collection?
    false
  end

  def create_policy
    :create?
  end

  def create_label
    I18n.t('actions.conversions.create.label')
  end
end
