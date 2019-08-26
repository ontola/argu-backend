# frozen_string_literal: true

class PageActionList < EdgeActionList
  has_action(
    :create,
    create_options.merge(
      label: -> { I18n.t('websites.type_new') },
      root_relative_iri: -> { expand_uri_template(:new_iri, parent_iri: 'o') },
      url: -> { RDF::DynamicURI(LinkedRails.iri(path: '/o')) }
    )
  )
  has_action(:redirect, http_method: :get, type: NS::SCHEMA[:Action])
end
