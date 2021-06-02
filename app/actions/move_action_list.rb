# frozen_string_literal: true

class MoveActionList < ApplicationActionList
  has_singular_create_action(
    description: -> { I18n.t('actions.default.move.description') },
    label: -> { I18n.t('actions.default.move.label') }
  )
end
