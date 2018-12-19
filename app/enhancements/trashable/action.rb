# frozen_string_literal: true

module Trashable
  module Action
    extend ActiveSupport::Concern

    included do
      include Destroyable::Action

      define_action(
        :trash,
        type: [NS::ARGU[:TrashAction], NS::SCHEMA[:Action]],
        policy: :trash?,
        image: 'fa-trash',
        url: -> { resource.iri },
        http_method: :delete,
        form: Request::TrashRequestForm,
        iri_template: :trash_iri
      )

      define_action(
        :untrash,
        type: [NS::ARGU[:UntrashAction], NS::SCHEMA[:Action]],
        policy: :untrash?,
        image: 'fa-eye',
        url: -> { untrash_iri(resource) },
        http_method: :put,
        form: Request::UntrashRequestForm,
        iri_template: :untrash_iri
      )
    end
  end
end
