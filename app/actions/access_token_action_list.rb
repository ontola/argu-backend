# frozen_string_literal: true

class AccessTokenActionList < ApplicationActionList
  has_action(
    :create,
    create_options.merge(
      collection: false,
      object: nil,
      form: AccessTokenForm,
      label: -> { I18n.t('actions.access_tokens.create.label') },
      include_object: true,
      policy: :create?,
      url: -> { RDF::DynamicURI(LinkedRails.iri(path: '/login')) }
    )
  )
end
