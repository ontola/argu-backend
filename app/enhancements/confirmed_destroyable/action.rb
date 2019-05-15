# frozen_string_literal: true

module ConfirmedDestroyable
  module Action
    extend ActiveSupport::Concern

    included do
      has_action(
        :destroy,
        type: [NS::SCHEMA[:Action], NS::ARGU[:DestroyAction]],
        policy: :destroy?,
        image: 'fa-close',
        url: -> { resource.iri(destroy: true) },
        http_method: :delete,
        form: Request::ConfirmedDestroyRequestForm,
        iri_path: -> { expand_uri_template(:delete_iri, parent_iri: resource.iri_path) }
      )
    end
  end
end
