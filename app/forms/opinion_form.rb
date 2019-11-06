# frozen_string_literal: true

class OpinionForm < ApplicationForm
  fields [
    {description: {description: -> { I18n.t('opinions.form.placeholder') }}},
    :hidden,
    :footer
  ]

  property_group(
    :footer,
    iri: NS::ONTOLA[:footerGroup],
    order: 99,
    properties: [
      creator: actor_step
    ]
  )

  property_group(
    :hidden,
    iri: NS::ONTOLA[:hiddenGroup],
    order: 98,
    properties: [
      is_opinion: {
        default_value: true
      }
    ]
  )
end
