# frozen_string_literal: true

class ShortnameForm < ApplicationForm
  fields [
    :shortname,
    {
      destination: {
        description: ->(r) { I18n.t('formtastic.hints.shortname.destination', iri_prefix: r.root.iri_prefix) }
      }
    },
    :unscoped
  ]
end
