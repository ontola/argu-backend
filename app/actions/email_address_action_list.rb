# frozen_string_literal: true

class EmailAddressActionList < ApplicationActionList
  has_resource_action(
    :send_confirmation,
    completed: -> { resource.confirmed? },
    policy: :confirm?,
    image: 'fa-send',
    url: lambda {
      RDF::DynamicURI(
        expand_uri_template(:confirmations_iri, 'user%5Bemail%5D': resource.email, with_hostname: true)
      )
    },
    http_method: :post,
    type: NS.ontola[:InlineAction]
  )

  has_resource_action(
    :make_primary,
    completed: -> { resource.primary? },
    policy: :make_primary?,
    image: 'fa-circle-o',
    url: -> { resource.iri('email_address%5Bprimary%5D': true) },
    http_method: :put,
    type: NS.ontola[:InlineAction]
  )
end
