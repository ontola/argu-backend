# frozen_string_literal: true

class ExportActionList < ApplicationActionList
  has_action(
    :create,
    create_options.merge(
      description: -> { I18n.t('exports.create_helper') }
    )
  )
end
