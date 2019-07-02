# frozen_string_literal: true

class UserActionList < ApplicationActionList
  extend LanguageHelper

  has_action(
    :privacy,
    type: NS::SCHEMA[:UpdateAction],
    policy: :update?,
    image: 'fa-update',
    url: -> { resource.iri },
    http_method: :put,
    form: ::Users::PrivacyForm,
    root_relative_iri: lambda do
      expand_uri_template(:edit_iri, form: :privacy, parent_iri: split_iri_segments(resource.iri_path))
    end
  )

  has_action(
    :notifications,
    type: NS::SCHEMA[:UpdateAction],
    policy: :update?,
    image: 'fa-update',
    url: -> { resource.iri },
    http_method: :put,
    form: ::Users::NotificationsForm,
    root_relative_iri: lambda do
      expand_uri_template(:edit_iri, form: :notifications, parent_iri: split_iri_segments(resource.iri_path))
    end
  )

  has_action(
    :authentication,
    type: NS::SCHEMA[:UpdateAction],
    policy: :update?,
    image: 'fa-update',
    url: -> { resource.iri },
    http_method: :put,
    form: ::Users::AuthenticationForm,
    root_relative_iri: lambda do
      expand_uri_template(:edit_iri, form: :authentication, parent_iri: split_iri_segments(resource.iri_path))
    end
  )

  has_action(
    :setup,
    type: NS::SCHEMA[:UpdateAction],
    policy: :update?,
    image: 'fa-update',
    url: -> { iri_from_template(:setup_iri) },
    http_method: :put,
    form: ::Users::SetupForm,
    root_relative_iri: -> { expand_uri_template(:setup_iri) }
  )

  has_action(
    :language,
    type: NS::SCHEMA[:UpdateAction],
    policy: :update?,
    image: 'fa-update',
    label: -> { I18n.t('set_language') },
    url: -> { iri_from_template(:languages_iri) },
    http_method: :put,
    form: ::Users::LanguageForm,
    root_relative_iri: -> { expand_uri_template(:languages_iri) }
  )
end
