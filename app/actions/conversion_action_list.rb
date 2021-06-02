# frozen_string_literal: true

class ConversionActionList < ApplicationActionList
  has_collection_create_action(
    label: -> { I18n.t('actions.conversions.create.label') }
  )
end
