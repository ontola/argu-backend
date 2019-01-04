# frozen_string_literal: true

module Actions
  class UserActions < Base
    extend LanguageHelper

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

    define_action(
      :setup,
      type: NS::SCHEMA[:UpdateAction],
      policy: :update?,
      image: 'fa-update',
      url: -> { iri_from_template(:setup_iri) },
      http_method: :put,
      form: ::Users::SetupForm,
      iri_template: :setup_iri
    )

    define_action(
      :language,
      type: NS::SCHEMA[:UpdateAction],
      policy: :update?,
      image: 'fa-update',
      label: -> { I18n.t('set_language') },
      url: -> { iri_from_template(:languages_iri) },
      http_method: :put,
      form: ::Users::LanguageForm,
      iri_template: :languages_iri
    )
  end
end
