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
        image: :trash,
        url: -> { resource.iri },
        http_method: :delete
      )

      define_action(
        :untrash,
        type: NS::ARGU[:UntrashAction],
        policy: :untrash?,
        image: :eye,
        url: -> { untrash_iri(resource) },
        http_method: :put
      )
    end
  end
end
