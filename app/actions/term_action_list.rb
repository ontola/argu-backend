# frozen_string_literal: true

class TermActionList < ApplicationActionList
  has_action(
    :create,
    create_options.merge(
      collection: false,
      description: -> { I18n.t('legal.continue_html', link: "[#{I18n.t('legal.documents.policy')}](/policy)") },
      label: -> { I18n.t('legal.documents.policy') },
      policy: nil
    )
  )
end
