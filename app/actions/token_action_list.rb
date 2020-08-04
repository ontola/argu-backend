# frozen_string_literal: true

class TokenActionList < ApplicationActionList
  has_action(
    :create,
    create_options.merge(
      collection: false,
      object: nil,
      label: -> { I18n.t('actions.tokens.create.label') },
      include_object: true,
      policy: :create?,
      url: -> { RDF::DynamicURI(LinkedRails.iri(path: '/login')) }
    )
  )
end
