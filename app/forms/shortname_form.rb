# frozen_string_literal: true

class ShortnameForm < ApplicationForm
  fields [
    :shortname,
    {
      destination: {
        description: -> { I18n.t('formtastic.hints.shortname.destination', iri_prefix: target.root.iri_prefix) }
      }
    },
    :unscoped
  ]
end
