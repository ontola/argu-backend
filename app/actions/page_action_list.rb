# frozen_string_literal: true

class PageActionList < EdgeActionList
  has_collection_create_action(
    label: -> { I18n.t('websites.type_new') },
    root_relative_iri: -> { expand_uri_template(:new_iri, parent_iri: 'o') },
    url: -> { LinkedRails.iri(path: '/o') }
  )

  has_resource_action(
    :language,
    form: ::Users::LanguageForm,
    http_method: :put,
    image: 'fa-update',
    label: -> { I18n.t('set_language') },
    object: -> { user_context.user },
    policy: :update?,
    policy_resource: -> { user_context.user },
    submit_label: -> { I18n.t('save') },
    type: NS::SCHEMA[:UpdateAction],
    url: -> { iri_from_template(:languages_iri) }
  )
end
