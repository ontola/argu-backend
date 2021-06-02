# frozen_string_literal: true

class ExportActionList < ApplicationActionList
  has_collection_create_action(
    description: -> { I18n.t('exports.create_helper') }
  )
end
