# frozen_string_literal: true

module Trashable
  module Action
    extend ActiveSupport::Concern

    included do
      include Destroyable::Action

      define_action(
        :trash,
        type: NS::ARGU[:TrashAction],
        policy: :trash?,
        image: 'fa-trash',
        url: -> { resource.iri },
        http_method: :delete,
        form: TrashRequestForm,
        iri_template: :trash_iri
      )

      define_action(
        :untrash,
        type: NS::ARGU[:UntrashAction],
        policy: :untrash?,
        image: 'fa-eye',
        url: -> { untrash_iri(resource) },
        http_method: :put,
        form: UntrashRequestForm,
        iri_template: :untrash_iri
      )
    end
  end
end
