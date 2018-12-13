# frozen_string_literal: true

module Actions
  class IdentityActions < Base
    define_action(
      :connect,
      type: -> { [NS::ARGU['ConnectIdentityAction'], NS::SCHEMA[:UpdateAction]] },
      description: lambda {
        I18n.t(
          'users.connect.text',
          from_type: resource.provider,
          from_name: resource.name,
          to_name: resource.connecting_user.display_name
        )
      },
      label: I18n.t('users.connect.title'),
      http_method: :post,
      form: Users::ConnectForm,
      url: lambda {
        RDF::DynamicURI(
          expand_uri_template(
            :user_connect,
            id: resource.connecting_user.id,
            token: resource.jwt_token,
            with_hostname: true
          )
        )
      },
      iri_template: :user_connect,
      iri_template_opts: -> { {id: resource.connecting_user.id, token: resource.jwt_token} }
    )
  end
end
