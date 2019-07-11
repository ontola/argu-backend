# frozen_string_literal: true

module Users
  class UnlockActionList < ApplicationActionList
    has_action(
      :create,
      create_options.merge(
        collection: false,
        description: -> { I18n.t('devise.unlocks.new.helper') },
        include_resource: true,
        label: -> { I18n.t('devise.unlocks.new.header') },
        policy: nil,
        url: -> { iri_from_template(:user_unlock) }
      )
    )

    has_action(
      :update,
      update_options.merge(
        label: -> { I18n.t('devise.unlocks.unlocked') },
        url: -> { iri_from_template(:user_unlock) }
      )
    )
  end
end
