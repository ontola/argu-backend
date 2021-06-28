# frozen_string_literal: true

class UserActionList < ApplicationActionList
  extend LanguageHelper

  has_collection_create_action(
    form: ::Users::RegistrationForm,
    label: -> { I18n.t('actions.users.create.label') },
    url: -> { LinkedRails.iri(path: '/users') }
  )

  has_resource_update_action(
    label: -> { I18n.t('actions.users.update.label') }
  )

  has_resource_destroy_action(
    confirmed_destroy_options(
      description: -> { I18n.t('actions.users.destroy.description', name: resource.display_name) },
      form: Users::DestroyForm
    )
  )

  has_singular_destroy_action(
    confirmed_destroy_options(
      description: -> { I18n.t('actions.users.destroy.description', name: resource.display_name) },
      form: Users::DestroyForm
    )
  )

  has_resource_action(
    :profile,
    update_resource_options(
      label: -> { I18n.t('profiles.edit.title') },
      form: ::Users::ProfileForm,
      root_relative_iri: nil
    )
  )

  has_singular_action(
    :setup,
    type: NS.schema.UpdateAction,
    policy: :update?,
    image: 'fa-update',
    url: -> { resource.iri },
    http_method: :put,
    form: Users::SetupForm,
    root_relative_iri: -> { expand_uri_template(:setup_iri) }
  )
end
