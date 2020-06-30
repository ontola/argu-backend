# frozen_string_literal: true

class MoveActionList < ApplicationActionList
  has_action(
    :create,
    create_options.merge(
      collection: false,
      description: -> { I18n.t('actions.default.move.description') },
      label: -> { I18n.t('actions.default.move.label') },
      object: nil,
      policy: :create?
    )
  )

  private

  def association_class
    Move
  end
end
