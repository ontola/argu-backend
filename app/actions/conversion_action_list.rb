# frozen_string_literal: true

class ConversionActionList < ApplicationActionList
  has_action(
    :create,
    create_options.merge(
      collection: false,
      label: -> { I18n.t('actions.conversions.convert.label') },
      object: nil,
      policy: :create?
    )
  )

  private

  def association_class
    Conversion
  end
end
