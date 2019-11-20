# frozen_string_literal: true

class SetupActionList < ApplicationActionList
  has_action(
    :update,
    update_options.merge(
      collection: false,
      include_resource: true,
      label: -> { I18n.t('actions.setups.update.label') },
      root_relative_iri: lambda {
        uri = resource.root_relative_iri.dup
        uri.fragment = nil
        uri.to_s
      },
      policy: nil
    )
  )
end
