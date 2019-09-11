# frozen_string_literal: true

class InviteForm < ApplicationForm
  include RegexHelper

  fields(
    [
      {addresses: {max_length: 5000, pattern: /\A(#{RegexHelper::SINGLE_EMAIL.source},?\s?)+\z/}},
      {
        message: {
          default_value: lambda do
            I18n.t('tokens.discussion.default_message', resource: target.edge.display_name)
          end,
          max_length: 5000
        }
      },
      {group_id: {sh_in: -> { target.edge.root.groups.map(&:iri) }}},
      {redirect_url: {default_value: -> { target.edge.iri.to_s }}},
      :hidden,
      :footer
    ]
  )

  property_group(
    :hidden,
    iri: NS::ONTOLA[:hiddenGroup],
    order: 98,
    properties: [
      {send_mail: {default_value: true}},
      {
        root_id: {
          default_value: -> { target.edge.root_id }
        }
      }
    ]
  )

  property_group(
    :footer,
    iri: NS::ONTOLA[:footerGroup],
    order: 99,
    properties: [
      creator: actor_selector
    ]
  )
end
