# frozen_string_literal: true

class SessionActionList < ApplicationActionList
  has_action(
    :create,
    create_options.merge(
      collection: false,
      include_object: true,
      label: -> { I18n.t('actions.sessions.create.label') },
      object: nil,
      policy: :create?,
      url: -> { LinkedRails.iri(path: '/u/sessions') },
      root_relative_iri: -> { resource.root_relative_iri }
    )
  )
end
