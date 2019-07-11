# frozen_string_literal: true

module Users
  class ConfirmationActionList < ApplicationActionList
    has_action(
      :create,
      create_options.merge(
        collection: false,
        include_resource: true,
        label: -> { I18n.t('devise.confirmations.edit.header') },
        policy: nil,
        url: -> { iri_from_template(:confirmations_iri) }
      )
    )
  end
end
