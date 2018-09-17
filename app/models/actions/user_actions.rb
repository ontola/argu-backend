# frozen_string_literal: true

module Actions
  class UserActions < Base
    define_action(
      :privacy,
      type: NS::SCHEMA[:UpdateAction],
      policy: :update?,
      image: 'fa-update',
      url: -> { resource.iri },
      http_method: :put,
      form: ::Users::PrivacyForm,
      iri_template: :edit_iri,
      iri_template_opts: {form: :privacy}
    )

    define_action(
      :notifications,
      type: NS::SCHEMA[:UpdateAction],
      policy: :update?,
      image: 'fa-update',
      url: -> { resource.iri },
      http_method: :put,
      form: ::Users::NotificationsForm,
      iri_template: :edit_iri,
      iri_template_opts: {form: :notifications}
    )

    define_action(
      :authentication,
      type: NS::SCHEMA[:UpdateAction],
      policy: :update?,
      image: 'fa-update',
      url: -> { resource.iri },
      http_method: :put,
      form: ::Users::AuthenticationForm,
      iri_template: :edit_iri,
      iri_template_opts: {form: :authentication}
    )
  end
end
