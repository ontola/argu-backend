# frozen_string_literal: true

class OpinionForm < ApplicationForm
  fields [
    {description: {description: -> { I18n.t('opinions.form.placeholder') }}},
    :hidden
  ]

  property_group(
    :hidden,
    iri: NS::ONTOLA[:hiddenGroup],
    properties: [
      is_opinion: {
        default_value: true
      }
    ]
  )
end
