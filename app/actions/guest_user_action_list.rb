# frozen_string_literal: true

class GuestUserActionList < ApplicationActionList
  extend LanguageHelper

  has_resource_action(
    :language,
    type: NS::SCHEMA[:UpdateAction],
    image: 'fa-update',
    label: -> { I18n.t('set_language') },
    submit_label: -> { I18n.t('save') },
    url: -> { iri_from_template(:languages_iri) },
    http_method: :put,
    form: ::Users::LanguageForm,
    root_relative_iri: -> { expand_uri_template(:languages_iri) }
  )
end
