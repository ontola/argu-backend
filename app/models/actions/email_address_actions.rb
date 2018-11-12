# frozen_string_literal: true

module Actions
  class EmailAddressActions < Base
    define_action(
      :send_confirmation,
      completed: -> { resource.confirmed? },
      type: NS::ARGU[:SendConfirmationAction],
      policy: :confirm?,
      image: 'fa-send',
      url: lambda {
        RDF::DynamicURI(
          expand_uri_template(:confirmations_iri, 'user%5Bemail%5D': resource.email, with_hostname: true)
        )
      },
      http_method: :post
    )

    define_action(
      :make_primary,
      completed: -> { resource.primary? },
      type: NS::ARGU[:MakePrimaryAction],
      policy: :make_primary?,
      image: 'fa-circle-o',
      url: -> { resource.iri('email_address%5Bprimary%5D': true) },
      http_method: :put
    )
  end
end
