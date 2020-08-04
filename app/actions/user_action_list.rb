# frozen_string_literal: true

class UserActionList < ApplicationActionList
  extend LanguageHelper

  has_action(
    :create,
    create_options.merge(
      form: ::Users::RegistrationForm,
      label: -> { I18n.t('actions.users.create.label') },
      url: -> { RDF::DynamicURI(LinkedRails.iri(path: '/users')) }
    )
  )

  has_action(
    :update,
    update_options.merge(
      label: -> { I18n.t('actions.users.update.label') }
    )
  )

  has_action(
    :destroy,
    confirmed_destroy_options.merge(
      description: -> { I18n.t('actions.users.destroy.description', name: resource.url || resource.generated_name) }
    )
  )

  has_action(
    :profile,
    update_options.merge(
      label: -> { I18n.t('profiles.edit.title') },
      form: ::Users::ProfileForm,
      root_relative_iri: nil
    )
  )

  has_action(
    :setup,
    type: NS::SCHEMA[:UpdateAction],
    policy: :update?,
    image: 'fa-update',
    url: -> { iri_from_template(:setup_iri) },
    http_method: :put,
    form: SetupForm,
    root_relative_iri: -> { expand_uri_template(:setup_iri) }
  )

  has_action(
    :language,
    type: NS::SCHEMA[:UpdateAction],
    policy: :update?,
    image: 'fa-update',
    label: -> { I18n.t('set_language') },
    submit_label: -> { I18n.t('save') },
    url: -> { iri_from_template(:languages_iri) },
    http_method: :put,
    form: ::Users::LanguageForm,
    root_relative_iri: -> { expand_uri_template(:languages_iri) }
  )
end
