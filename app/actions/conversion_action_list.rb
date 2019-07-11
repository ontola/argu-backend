# frozen_string_literal: true

class ConversionActionList < ApplicationActionList
  has_action(
    :create,
    create_options.merge(
      collection: false,
      label: -> { I18n.t('actions.conversions.create.label') },
      policy: :create?
    )
  )

  private

  def association_class
    Conversion
  end
end
