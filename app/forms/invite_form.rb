# frozen_string_literal: true

class InviteForm < RailsLD::Form
  include RegexHelper

  fields(
    [
      {addresses: {max_length: 5000, pattern: /\A(#{RegexHelper::SINGLE_EMAIL.source},?\s?)+\z/}},
      {
        message: {
          default_value: lambda do |r|
            I18n.t('tokens.discussion.default_message', resource: r.form.target.edge.display_name)
          end,
          max_length: 5000
        }
      },
      {group_id: {sh_in: ->(r) { r.form.target.edge.root.groups.map(&:iri) }}},
      :hidden,
      :footer
    ]
  )

  property_group(
    :hidden,
    iri: NS::ONTOLA[:hiddenGroup],
    properties: [
      {send_mail: {default_value: true}},
      {
        root_id: {
          default_value: ->(r) { r.form.target.edge.root_id }
        }
      },
      {redirect_url: {default_value: ->(r) { r.form.target.edge.iri }}}
    ]
  )

  property_group(
    :footer,
    iri: NS::ONTOLA[:footerGroup],
    properties: [
      creator: actor_selector
    ]
  )
end
